module ApplicationHelper
  # Map a sidebar section key to its route. Modules not built yet point to "#".
  def section_path(key)
    case key
    when "dashboard"   then dashboard_path
    when "records"     then records_path
    when "master_data" then master_data_path
    when "costing"     then cost_cards_path
    when "fabric"      then fabric_lots_path
    when "emb_party"   then emb_parties_path
    when "emb_master"  then emb_master_path
    when "cutwork_party" then cutwork_parties_path
    when "handmade_party" then handmade_parties_path
    when "prod_party"  then production_parties_path
    when "prod_khata"  then production_khata_path
    when "prod_payroll" then production_payroll_path
    when "cutwork_bill" then cutwork_billing_path
    when "handwork_bill" then handwork_billing_path
    when "khatta_emb"  then khatta_embs_path
    when "khatta_bill" then khatta_billing_path
    when "instock"     then stock_entries_path
    when "stitching"        then stitching_path
    when "production_sheet" then production_sheets_path
    when "stitch_cost"      then stitching_cost_cards_path
    when "cutwork_prog"     then cutwork_progress_path
    when "handmade_prog"    then handmade_progress_path
    when "analytics"   then analytics_path
    when "team"        then team_index_path
    else "#"
    end
  end

  # Section is "live" (clickable) vs a placeholder stub.
  def section_live?(key)
    %w[dashboard records master_data costing fabric emb_party emb_master cutwork_party handmade_party prod_party prod_khata prod_payroll cutwork_bill handwork_bill khatta_emb khatta_bill instock stitching production_sheet stitch_cost cutwork_prog handmade_prog analytics team].include?(key)
  end

  def active_section?(key)
    section_live?(key) && current_page?(section_path(key))
  end

  def rs(n)
    "Rs " + number_with_delimiter(n.to_f.round)
  end
end
