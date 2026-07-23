# Provides analytics datasets for charts and exports.
# Uses representative figures until the live modules (inventory, sales, payroll)
# are wired in. Supports simple month-range + dataset filtering.
class AnalyticsData
  MONTHS = %w[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec].freeze

  # Monthly finished-goods sales (pieces)
  SALES = [820, 760, 910, 1180, 1340, 1290, 0, 0, 0, 0, 1100, 980].freeze

  # Top designs by quantity sold
  TOP_DESIGNS = [
    ["AR-178", 1680], ["AR-206", 1320], ["AR-06", 1150],
    ["AR-35", 980], ["AR-205", 760], ["AR-212", 540]
  ].freeze

  # Weekly wage bill (last 6 weeks, PKR)
  WAGES = [58200, 61100, 63370, 59800, 64250, 67010].freeze

  DATASETS = { "sales" => "Monthly Sales", "designs" => "Top Designs", "wages" => "Weekly Wages" }.freeze

  def initialize(params = {})
    @from    = (params[:from].presence || 1).to_i.clamp(1, 12)
    @to      = (params[:to].presence || 12).to_i.clamp(1, 12)
    @from, @to = @to, @from if @from > @to
    @dataset = DATASETS.key?(params[:dataset].to_s) ? params[:dataset].to_s : "sales"
  end

  attr_reader :from, :to, :dataset

  def month_range = (@from - 1)..(@to - 1)

  def sales_chart
    { labels: MONTHS[month_range], data: SALES[month_range] }
  end

  def designs_chart
    { labels: TOP_DESIGNS.map(&:first), data: TOP_DESIGNS.map(&:last) }
  end

  def wages_chart
    labels = (1..WAGES.size).map { |i| "W#{i}" }
    { labels: labels, data: WAGES }
  end

  def kpis
    sold = SALES[month_range].sum
    [
      { label: "Pieces Sold",      value: number_with_delimiter(sold) },
      { label: "Top Design",       value: TOP_DESIGNS.first.first },
      { label: "Avg Weekly Wage",  value: "Rs #{number_with_delimiter(WAGES.sum / WAGES.size)}" },
      { label: "Active Designs",   value: 122 }
    ]
  end

  # Rows for export (depends on selected dataset)
  def export_title
    DATASETS[@dataset]
  end

  def export_rows
    case @dataset
    when "designs"
      [%w[Design QtySold]] + TOP_DESIGNS.map { |n, q| [n, q] }
    when "wages"
      [%w[Week WageBillPKR]] + WAGES.each_with_index.map { |w, i| ["W#{i + 1}", w] }
    else
      c = sales_chart
      [%w[Month PiecesSold]] + c[:labels].each_with_index.map { |m, i| [m, c[:data][i]] }
    end
  end

  private

  def number_with_delimiter(n)
    n.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
end
