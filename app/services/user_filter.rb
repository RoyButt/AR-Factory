# Advanced, datahub-style filter engine for the Users table.
# Mirrors the reference data-table filter: per-column variant + operators,
# AND/OR join, server-side applied as a single ActiveRecord WHERE.
#
# Filter condition shape (from params):
#   { field: "name", operator: "iLike", value: "...", value2: "..." }
# plus a global join: "and" | "or".
class UserFilter
  # Whitelisted, filterable columns. `sql` is the ONLY thing interpolated into
  # SQL — never user input — so this list is the security boundary.
  COLUMNS = [
    { id: "name",       label: "Name",       variant: "text",    sql: "users.name" },
    { id: "email",      label: "Email",      variant: "text",    sql: "users.email" },
    { id: "role",       label: "Role",       variant: "select",  sql: "users.role",
      options: User::ROLES.map { |r| { value: r, label: r.titleize.sub("Superadmin", "Super Admin") } } },
    { id: "view_only",  label: "View Only",  variant: "boolean", sql: "users.view_only" },
    { id: "created_at", label: "Created",    variant: "date",    sql: "users.created_at" }
  ].freeze

  # Operators per variant. value_kind: none (no input) | one | two (between).
  OPERATORS = {
    "text" => [
      { value: "iLike",      label: "Contains",       value_kind: "one" },
      { value: "notILike",   label: "Does not contain", value_kind: "one" },
      { value: "eq",         label: "Is",             value_kind: "one" },
      { value: "ne",         label: "Is not",         value_kind: "one" },
      { value: "isEmpty",    label: "Is empty",       value_kind: "none" },
      { value: "isNotEmpty", label: "Is not empty",   value_kind: "none" }
    ],
    "select" => [
      { value: "eq",         label: "Is",             value_kind: "one" },
      { value: "ne",         label: "Is not",         value_kind: "one" },
      { value: "isEmpty",    label: "Is empty",       value_kind: "none" },
      { value: "isNotEmpty", label: "Is not empty",   value_kind: "none" }
    ],
    "boolean" => [
      { value: "eq",         label: "Is",             value_kind: "one" }
    ],
    "date" => [
      { value: "eq",         label: "Is on",          value_kind: "one" },
      { value: "lt",         label: "Before",         value_kind: "one" },
      { value: "gt",         label: "After",          value_kind: "one" },
      { value: "isBetween",  label: "Is between",     value_kind: "two" },
      { value: "isEmpty",    label: "Is empty",       value_kind: "none" },
      { value: "isNotEmpty", label: "Is not empty",   value_kind: "none" }
    ]
  }.freeze

  def self.column(id)
    COLUMNS.find { |c| c[:id] == id.to_s }
  end

  # Config consumed by the JS filter builder.
  def self.js_config
    { columns: COLUMNS, operators: OPERATORS }
  end

  def initialize(conditions, join)
    @conditions = Array(conditions).map { |c| c.respond_to?(:to_unsafe_h) ? c.to_unsafe_h : c }
    @join = %w[and or].include?(join.to_s) ? join.to_s : "and"
  end

  attr_reader :join

  def apply(scope = User.all)
    fragments = []
    binds = []

    @conditions.each do |c|
      col = self.class.column(c["field"] || c[:field])
      next unless col
      frag, frag_binds = build(col, (c["operator"] || c[:operator]).to_s,
                               (c["value"] || c[:value]), (c["value2"] || c[:value2]))
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
    needs_value = OPERATORS[col[:variant]].find { |o| o[:value] == operator }&.dig(:value_kind)

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
    when "ne"
      v.empty? ? nil : ["(#{sql} <> ? OR #{sql} IS NULL)", [v]]
    when "lt"  then v.empty? ? nil : ["#{sql} < ?", [v]]
    when "lte" then v.empty? ? nil : ["#{sql} <= ?", [v]]
    when "gt"  then v.empty? ? nil : ["#{sql} > ?", [v]]
    when "gte" then v.empty? ? nil : ["#{sql} >= ?", [v]]
    when "isBetween"
      v2 = value2.to_s.strip
      return nil if v.empty? || v2.empty?
      ["DATE(#{sql}) BETWEEN ? AND ?", [v, v2]]
    when "isEmpty"    then ["(#{sql} IS NULL OR #{sql} = '')", []]
    when "isNotEmpty" then ["(#{sql} IS NOT NULL AND #{sql} <> '')", []]
    else nil
    end
  end
end
