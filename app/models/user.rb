class User < ApplicationRecord
  has_secure_password

  # Team roles
  ROLES = %w[superadmin admin operator].freeze

  # All sidebar sections in display order. key => [label, icon]
  # In production-flow order: Cost → Design (per-pc) → Fabric Lot → Production …
  SECTIONS = {
    "dashboard"   => ["Dashboard",     "▦"],
    "costing"     => ["Fabric Cost Card", "🧾"],
    "master_data" => ["Designs (AR)",  "📐"],
    "fabric"      => ["Fabric Lots",   "◇"],
    "emb_party"   => ["Emb Party",     "🧵"],
    "emb_master"  => ["Emb Master",    "🧑‍🔧"],
    "cutwork_party" => ["Cutwork Party", "✂"],
    "handmade_party" => ["Handmade Party", "🖐"],
    "prod_party"  => ["Production Parties", "🧷"],
    "khatta_emb"  => ["Khatta (Emb)",     "📒"],
    "khatta_bill" => ["Khatta (Billing)", "💰"],
    "prod_khata"  => ["Detail Ledger", "📖"],
    "prod_payroll" => ["Weekly Pay", "🗓"],
    "cutwork_bill" => ["Cutwork (Billing)", "✂"],
    "handwork_bill" => ["Handwork (Billing)", "🖐"],
    "instock"     => ["In Stock",         "📦"],
    "stitching"        => ["Stitching",        "🪡"],
    "production_sheet" => ["Production Sheet", "📄"],
    "stitch_cost"      => ["Stitching Cost Card", "✂️"],
    "cutwork_prog"     => ["Cutwork Progress", "✂"],
    "handmade_prog"    => ["Handmade Progress", "🖐"],
    "embroidery"  => ["Embroidery",    "✚"],
    "production"  => ["Production",     "⚙"],
    "inventory"   => ["Inventory",     "▣"],
    "payroll"     => ["Payroll",       "◷"],
    "records"     => ["Tracking",      "🗂"],
    "analytics"   => ["Analytics",     "📊"],
    "team"        => ["Team",          "👥"]
  }.freeze

  serialize :allowed_sections, Array

  before_validation { self.email = email.to_s.strip.downcase }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, inclusion: { in: ROLES }

  def display_role
    { "superadmin" => "Super Admin", "admin" => "Admin", "operator" => "Operator" }[role] || role.to_s.titleize
  end

  def superadmin? = role == "superadmin"
  def admin?      = role == "admin"
  def operator?   = role == "operator"

  # Super Admin always sees every section; others see only their allowed list.
  def sections
    return SECTIONS.keys if superadmin?
    (allowed_sections || []).map(&:to_s)
  end

  def can_see?(key)
    sections.include?(key.to_s)
  end

  # Who may open the Team module and edit users.
  def can_manage_team?
    (superadmin? || admin?) && !view_only?
  end

  # General "can change data" gate (hides create/edit/delete for view-only users).
  def can_edit?
    !view_only?
  end
end
