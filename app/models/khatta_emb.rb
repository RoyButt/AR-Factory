class KhattaEmb < ApplicationRecord
  belongs_to :fabric_lot, optional: true
  has_many :khatta_deliveries, dependent: :destroy
  has_many :claim_colors, dependent: :destroy

  # Replace this dispatch's colour-lines for one claim kind ("emb" or "stitch") and keep the
  # integer claim total in sync (billing reads claim_suits / stitch_claim_suits).
  def replace_claim_colors!(kind, lines)
    transaction do
      claim_colors.where(kind: kind).delete_all
      Array(lines).each do |ln|
        s = ln[:suits].to_i
        next if s <= 0
        claim_colors.create!(kind: kind, fabric_lot_color_id: ln[:color_id].presence,
                             color_name: ln[:color_name], suits: s)
      end
      total = claim_colors.where(kind: kind).sum(:suits)
      update_column(kind == "stitch" ? :stitch_claim_suits : :claim_suits, total)
    end
  end
  accepts_nested_attributes_for :khatta_deliveries, allow_destroy: true,
    reject_if: ->(a) { a["suits"].to_i.zero? }

  validates :contractor, presence: true

  # Total suits returned = sum of all deliveries.
  def returned
    khatta_deliveries.sum { |d| d.suits.to_i }
  end
  alias_method :suits_returned, :returned

  # Suits still out at embroidery = sent − returned.
  def pending
    suits_sent.to_i - returned
  end

  def complete?
    pending <= 0
  end

  # EMB Cost per suit for this design, from its cost card.
  def emb_cost
    CostCard.find_by(code: design_code)&.emb_cost.to_f
  end

  # Bill = total suits returned × EMB cost per suit.
  def bill
    (returned * emb_cost).round(2)
  end

  # ---- Auto-fetched dispatches from the fabric lots ----
  # One row per (Laat + Contractor + Design). Suits sent = Σ (Machine Head × number of colours)
  # over that group's design lines. Returns are attached via a matching KhattaEmb (this table).
  Dispatch = Struct.new(:lot, :contractor, :design, :suits_sent, :emb, :emb_cost, :total_rate, :cm, keyword_init: true) do
    def laat;        lot.laat_number; end
    def returned;    emb ? emb.returned : 0; end
    def claim_suits;        emb ? emb.claim_suits.to_i : 0; end
    def stitch_claim_suits; emb ? emb.stitch_claim_suits.to_i : 0; end
    # Pending = sent − returned − claimed (a claim closes the shortfall as damaged).
    def pending;     suits_sent - returned - claim_suits; end
    # Effective rate = the saved override if set, else the cost-card EMB cost. Drives the Bill.
    def rate;        (emb && !emb.rate.nil?) ? emb.rate.to_f : emb_cost.to_f; end
    # Bill = (returned − suits ruined at stitching) × rate — ruined suits aren't paid for embroidery.
    def bill
      ov = emb && emb.bill_override
      ov.nil? ? ([returned - stitch_claim_suits, 0].max * rate).round(2) : ov.to_f
    end
    def bill_overridden?;  emb && !emb.bill_override.nil?; end
    def claim_overridden?; emb && !emb.claim_override.nil?; end
    # Claim = claim_suits × (Total − CM) from the cost card, unless a manual override is saved.
    def claim_per_suit; (total_rate.to_f - cm.to_f).round(2); end
    def claim_amount
      ov = emb && emb.claim_override
      ov.nil? ? (claim_suits * claim_per_suit).round(2) : ov.to_f
    end
    # Stitch claim = suits ruined during stitching × (Total − CM) — contractor owes for these.
    def stitch_claim_amount; (stitch_claim_suits * claim_per_suit).round(2); end
    # Total billing = embroidery bill + claim recovered from the contractor.
    def total_bill;  (bill + claim_amount).round(2); end
    def deliveries;  emb ? emb.khatta_deliveries.to_a : []; end
    def last_date;   deliveries.map(&:delivered_on).compact.max || (emb && emb.returned_on); end
    def dom_id;      "d-#{lot.id}-#{contractor.to_s.parameterize}-#{design.to_s.parameterize}"; end
  end

  def self.dispatches
    cost = CostCard.all.each_with_object({}) do |c, h|
      h[c.code] = { emb: c.emb_subtotal.to_f, total: c.total.to_f, cm: c.cm.to_f }   # EMB sub-total + Total (both before final add-ons)
    end
    emb_by_key = includes(:khatta_deliveries).where.not(fabric_lot_id: nil)
                 .index_by { |k| [k.fabric_lot_id, k.contractor.to_s, k.design_code.to_s] }
    lots = FabricLot.includes(:fabric_lot_colors, fabric_lot_lines: { design_variant: :design }).order(created_at: :desc)
    rows = []
    lots.each do |lot|
      ncol = lot.fabric_lot_colors.size
      lot.fabric_lot_lines
         .select { |l| l.contractor.present? && l.design_variant }
         .group_by { |l| [l.contractor, l.design_variant.design.code] }
         .each do |(contractor, code), lines|
        suits = lines.sum { |l| l.heads * ncol }
        emb   = emb_by_key[[lot.id, contractor.to_s, code.to_s]]
        info  = cost[code] || {}
        rows << Dispatch.new(lot: lot, contractor: contractor, design: code, suits_sent: suits, emb: emb,
                             emb_cost: info[:emb].to_f, total_rate: info[:total].to_f, cm: info[:cm].to_f)
      end
    end
    rows
  end
end
