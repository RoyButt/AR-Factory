class DashboardController < ApplicationController
  before_action :require_login

  def index
    # Placeholder KPIs — wired to live models as modules are built.
    @kpis = [
      { label: "Designs",          value: 122,        sub: "active articles" },
      { label: "Stock Balance",    value: "8,140",    sub: "pieces in hand" },
      { label: "Items to Reorder", value: 4,          sub: "below threshold" },
      { label: "Open Embroidery",  value: 6,          sub: "lots out" },
      { label: "Weekly Wage Bill", value: "Rs 63,370", sub: "current week" },
      { label: "WIP Lots",         value: 9,          sub: "in production" }
    ]

    @modules = [
      ["Inventory",   "Stock IN / OUT / Balance + reorder"],
      ["Cost Cards",  "Rate calculator with all formulas"],
      ["Embroidery",  "Contractor jobs — out / in / billing"],
      ["Production",  "Daily grid + Laat stage progress"],
      ["Payroll",     "Weekly piece-rate khata + report"],
      ["Fabric",      "Purchasing, rates & lot consumption"]
    ]

    # Production pipeline (Laat progress) — drives the tabbed tracker.
    @lots = ProductionLot.order(:created_at)
  end
end
