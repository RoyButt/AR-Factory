class MasterDataController < ApplicationController
  before_action :require_login
  before_action :require_section

  TABS = %w[designs fabric workers settings].freeze

  # Human-readable formula reference (shown on the Formulas tab). `keys` are the
  # editable Setting constants each formula depends on.
  FORMULAS = [
    { name: "EMB Consumption",
      expr: "CEILING( emb_factor × heads × repeats , rounding_step )",
      desc: "Fabric (gaz) consumed by the embroidery for one suit of a variant.",
      keys: %w[emb_factor rounding_step] },
    { name: "Backup Consumption",
      expr: "CEILING( (Tr + Back + Bazoo + Kali + Falas) ÷ backup_divisor × heads , rounding_step )",
      desc: "Extra fabric for the component panels (trousers, back, bazoo, kali, falas).",
      keys: %w[backup_divisor rounding_step] },
    { name: "Per-Piece Average",
      expr: "( EMB Consumption + Backup Consumption ) ÷ heads",
      desc: "Average fabric consumed per single suit.",
      keys: [] },
    { name: "Embroidery File Line",
      expr: "ROUND( stitch ÷ stitch_divisor × rate × heads , 0 ) × repeats",
      desc: "Cost of one embroidery file (panel / kali / bazoo …) on a cost card.",
      keys: %w[stitch_divisor] },
    { name: "EMB Cost",
      expr: "Σ(embroidery file lines) + emb_addon",
      desc: "Total embroidery cost line on a design cost card.",
      keys: %w[emb_addon] },
    { name: "Fabric Cost",
      expr: "fabric_rate × fabric_multiplier",
      desc: "Fabric cost per suit (gaz per suit × fabric rate).",
      keys: %w[fabric_multiplier] },
    { name: "Final Rate",
      expr: "Total cost + final_addon",
      desc: "Final selling rate = sum of all cost lines + margin / round-off.",
      keys: %w[final_addon] },
    { name: "Suits from Fabric",
      expr: "remaining_gaz ÷ gaz_per_suit_consumed   ·   issued_gaz ÷ gaz_per_suit_issued",
      desc: "Convert fabric (gaz) into number of suits.",
      keys: %w[gaz_per_suit_consumed gaz_per_suit_issued] },
    { name: "Reorder Quantity",
      expr: "monthly_avg × (reorder_cover_days ÷ 30) + monthly_avg × reorder_buffer_factor",
      desc: "Suggested reorder quantity based on average monthly sales.",
      keys: %w[reorder_cover_days reorder_buffer_factor] }
  ].freeze

  def index
    @tab = TABS.include?(params[:tab]) ? params[:tab] : "designs"
    @designs = Design.includes(:design_variants, picture_attachment: :blob).order(:code)
    @fabric_types = FabricType.order(:name, year: :desc)
    @workers = Worker.order(:name)
    @settings = Setting.order(:grouping, :id)
    @settings_by_key = @settings.index_by(&:key)
    @formulas = FORMULAS
  end

  private

  def require_section
    redirect_to dashboard_path, alert: "You don't have access to Master Data." unless current_user.can_see?("master_data")
  end
end
