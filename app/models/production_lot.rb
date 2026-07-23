class ProductionLot < ApplicationRecord
  has_many :lot_attachments, dependent: :destroy

  # Stage keys (also used to tag attachments + label edit-form sections), in flow order.
  STAGES = %w[emb_out emb_in emb_pay production cutwork cutwork_pay overlock overlock_pay
              handmade_pay handmade_return press out].freeze

  STAGE_LABELS = {
    "emb_out" => "Embroidery (Out)", "emb_in" => "Embroidery (In)", "emb_pay" => "Embroidery Payment",
    "production" => "Production", "cutwork" => "CutWork", "cutwork_pay" => "CutWork Payment",
    "overlock" => "OverLock", "overlock_pay" => "OverLock Payment",
    "handmade_pay" => "HandMade Payment", "handmade_return" => "HandMade Return",
    "press" => "Press", "out" => "Out"
  }.freeze

  # Ordered production pipeline. Cloth flows left -> right.
  def pipeline
    stages = [
      emb_out("Embroidery", emb_name, emb_sent_date, emb_sent_qty),
      handoff("emb_in",  "Embroidery In", emb_received_date, "Received back", emb_sent_qty, emb_received_qty),
      payment("emb_pay", "Embroidery Payment", emb_paid, emb_paid_date),
      movement("production", "Production", production_date),
      handoff("cutwork", "CutWork", cutwork_sent_date, "Sent for cutwork", cutwork_sent_qty, cutwork_received_qty),
      payment("cutwork_pay", "CutWork Payment", cutwork_paid, cutwork_paid_date),
      handoff("overlock", "OverLock", overlock_sent_date, "Sent for overlock", overlock_sent_qty, overlock_received_qty),
      payment("overlock_pay", "OverLock Payment", overlock_paid, overlock_paid_date),
      payment("handmade_pay", "HandMade Payment", handmade_paid, handmade_paid_date),
      handoff("handmade_return", "HandMade Return", handmade_return_date, "Returned", handmade_sent_qty, handmade_received_qty),
      movement("press", "Press", press_date),
      movement("out", "Out", out_date, sub: "To market")
    ]
    current = stages.find { |s| s[:status] == :pending }
    current[:status] = :current if current
    stages
  end

  def progress_pct
    s = pipeline
    done = s.count { |x| %i[done shortfall].include?(x[:status]) }
    ((done.to_f / s.size) * 100).round
  end

  def title
    [design, (laat_number.present? ? "Laat ##{laat_number}" : nil)].compact.join(" · ")
  end

  def attachments_for(stage_key)
    lot_attachments.select { |a| a.stage == stage_key.to_s }
  end

  def attachment_count(stage_key)
    attachments_for(stage_key).size
  end

  def issues
    list = []

    handoffs = {
      "Embroidery" => [emb_sent_qty, emb_received_qty, emb_sent_date, emb_received_date],
      "CutWork"    => [cutwork_sent_qty, cutwork_received_qty, cutwork_sent_date, nil],
      "OverLock"   => [overlock_sent_qty, overlock_received_qty, overlock_sent_date, nil],
      "HandMade"   => [handmade_sent_qty, handmade_received_qty, nil, handmade_return_date]
    }
    handoffs.each do |name, (sent, back, sent_date, _)|
      if sent && back && back < sent
        list << { severity: :high, type: "Short delivery", label: "#{name}: #{sent - back} missing",
                  detail: "Sent #{sent}, only #{back} returned" }
      elsif sent_date.present? && back.nil?
        list << { severity: :medium, type: "Awaiting return", label: "#{name}: not returned yet",
                  detail: "Sent on #{sent_date.strftime('%d %b %Y')}#{", #{sent} pcs" if sent}" }
      end
    end

    payments = {
      "Embroidery" => [emb_sent_qty.present? || emb_sent_date.present?, emb_paid],
      "CutWork"    => [cutwork_sent_date.present? || cutwork_sent_qty.present?, cutwork_paid],
      "OverLock"   => [overlock_sent_date.present? || overlock_sent_qty.present?, overlock_paid],
      "HandMade"   => [handmade_sent_qty.present? || handmade_return_date.present?, handmade_paid]
    }
    payments.each do |name, (active, paid)|
      next unless active && !paid
      list << { severity: :medium, type: "Payment pending", label: "#{name} payment unpaid",
                detail: "Work done, payment not recorded" }
    end

    order = { high: 0, medium: 1, low: 2 }
    list.sort_by { |i| order[i[:severity]] }
  end

  def has_issues?
    issues.any?
  end

  private

  def emb_out(title, name, sent_date, sent_qty)
    {
      key: "emb_out", title: title, sub: name.presence, kind: :origin,
      value: sent_date ? sent_date.strftime("%d %b %Y") : nil,
      sent: sent_qty,
      status: (sent_date.present? || name.present?) ? :done : :pending
    }
  end

  def movement(key, title, value, sub: nil)
    {
      key: key, title: title, sub: sub, kind: :stage,
      value: value ? value.strftime("%d %b %Y") : nil,
      status: value.present? ? :done : :pending
    }
  end

  def handoff(key, title, sent_date, sub, sent_qty, back_qty)
    short = (sent_qty && back_qty) ? (sent_qty - back_qty) : nil
    status =
      if short && short > 0 then :shortfall
      elsif back_qty.present? then :done
      else :pending
      end
    {
      key: key, title: title, sub: sub, kind: :handoff,
      value: sent_date ? sent_date.strftime("%d %b %Y") : nil,
      sent: sent_qty, back: back_qty, short: (short && short > 0 ? short : nil),
      status: status
    }
  end

  def payment(key, title, paid, date)
    {
      key: key, title: title, sub: nil, kind: :payment,
      value: date ? date.strftime("%d %b %Y") : nil,
      paid: paid, status: paid ? :done : :pending
    }
  end
end
