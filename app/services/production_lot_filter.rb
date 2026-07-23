# Advanced datahub-style filter for production lots (Records table).
# Same condition model as UserFilter: { field, operator, value, value2 } + AND/OR join.
class ProductionLotFilter
  COLUMNS = [
    { id: "design",               label: "Design",          variant: "text",    sql: "production_lots.design" },
    { id: "emb_name",             label: "EMB Name",        variant: "text",    sql: "production_lots.emb_name" },
    { id: "laat_number",          label: "Laat #",          variant: "text",    sql: "production_lots.laat_number" },
    { id: "total_suit",           label: "Total Suits",     variant: "number",  sql: "production_lots.total_suit" },
    { id: "emb_sent_date",        label: "Embroidery Sent", variant: "date",    sql: "production_lots.emb_sent_date" },
    { id: "emb_received_date",    label: "Embroidery In",   variant: "date",    sql: "production_lots.emb_received_date" },
    { id: "emb_paid",             label: "Embroidery Paid", variant: "boolean", sql: "production_lots.emb_paid" },
    { id: "production_date",      label: "Production",      variant: "date",    sql: "production_lots.production_date" },
    { id: "cutwork_sent_date",    label: "CutWork Sent",    variant: "date",    sql: "production_lots.cutwork_sent_date" },
    { id: "cutwork_paid",         label: "CutWork Paid",    variant: "boolean", sql: "production_lots.cutwork_paid" },
    { id: "overlock_sent_date",   label: "OverLock Sent",   variant: "date",    sql: "production_lots.overlock_sent_date" },
    { id: "overlock_paid",        label: "OverLock Paid",   variant: "boolean", sql: "production_lots.overlock_paid" },
    { id: "handmade_return_date", label: "HandMade Return", variant: "date",    sql: "production_lots.handmade_return_date" },
    { id: "handmade_paid",        label: "HandMade Paid",   variant: "boolean", sql: "production_lots.handmade_paid" },
    { id: "press_date",           label: "Press",           variant: "date",    sql: "production_lots.press_date" },
    { id: "out_date",             label: "Out",             variant: "date",    sql: "production_lots.out_date" }
  ].freeze

  OPERATORS = {
    "text" => [
      { value: "iLike", label: "Contains", value_kind: "one" },
      { value: "notILike", label: "Does not contain", value_kind: "one" },
      { value: "eq", label: "Is", value_kind: "one" },
      { value: "ne", label: "Is not", value_kind: "one" },
      { value: "isEmpty", label: "Is empty", value_kind: "none" },
      { value: "isNotEmpty", label: "Is not empty", value_kind: "none" }
    ],
    "number" => [
      { value: "eq", label: "=", value_kind: "one" },
      { value: "ne", label: "≠", value_kind: "one" },
      { value: "lt", label: "<", value_kind: "one" },
      { value: "lte", label: "≤", value_kind: "one" },
      { value: "gt", label: ">", value_kind: "one" },
      { value: "gte", label: "≥", value_kind: "one" },
      { value: "isBetween", label: "Between", value_kind: "two" },
      { value: "isEmpty", label: "Is empty", value_kind: "none" },
      { value: "isNotEmpty", label: "Is not empty", value_kind: "none" }
    ],
    "boolean" => [
      { value: "eq", label: "Is", value_kind: "one" }
    ],
    "date" => [
      { value: "eq", label: "Is on", value_kind: "one" },
      { value: "lt", label: "Before", value_kind: "one" },
      { value: "gt", label: "After", value_kind: "one" },
      { value: "isBetween", label: "Between", value_kind: "two" },
      { value: "isEmpty", label: "Is empty", value_kind: "none" },
      { value: "isNotEmpty", label: "Is not empty", value_kind: "none" }
    ]
  }.freeze

  def self.column(id) = COLUMNS.find { |c| c[:id] == id.to_s }
  def self.js_config = { columns: COLUMNS, operators: OPERATORS }

  def initialize(conditions, join)
    @conditions = Array(conditions)
    @join = %w[and or].include?(join.to_s) ? join.to_s : "and"
  end

  attr_reader :join

  def apply(scope = ProductionLot.all)
    fragments = []
    binds = []
    @conditions.each do |c|
      col = self.class.column(c["field"])
      next unless col
      frag, frag_binds = build(col, c["operator"].to_s, c["value"], c["value2"])
      next if frag.nil?
      fragments << "(#{frag})"
      binds.concat(frag_binds)
    end
    return scope if fragments.empty?
    scope.where(fragments.join(" #{@join.upcase} "), *binds)
  end

  private

  def build(col, operator, value, value2)
    sql = col[:sql]
    v = value.to_s.strip
    case operator
    when "iLike"      then v.empty? ? nil : ["#{sql} LIKE ?", ["%#{v}%"]]
    when "notILike"   then v.empty? ? nil : ["#{sql} NOT LIKE ?", ["%#{v}%"]]
    when "eq"
      return nil if v.empty?
      case col[:variant]
      when "boolean" then ["#{sql} = ?", [v == "true"]]
      when "date"    then ["DATE(#{sql}) = ?", [v]]
      else ["#{sql} = ?", [v]]
      end
    when "ne"  then v.empty? ? nil : ["(#{sql} <> ? OR #{sql} IS NULL)", [v]]
    when "lt"  then v.empty? ? nil : ["#{sql} < ?", [v]]
    when "lte" then v.empty? ? nil : ["#{sql} <= ?", [v]]
    when "gt"  then v.empty? ? nil : ["#{sql} > ?", [v]]
    when "gte" then v.empty? ? nil : ["#{sql} >= ?", [v]]
    when "isBetween"
      v2 = value2.to_s.strip
      return nil if v.empty? || v2.empty?
      col[:variant] == "date" ? ["DATE(#{sql}) BETWEEN ? AND ?", [v, v2]] : ["#{sql} BETWEEN ? AND ?", [v, v2]]
    when "isEmpty"    then ["#{sql} IS NULL", []]
    when "isNotEmpty" then ["#{sql} IS NOT NULL", []]
    else nil
    end
  end
end
