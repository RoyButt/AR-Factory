require "csv"

class RecordsController < ApplicationController
  before_action :require_login
  before_action :require_section

  def index
    @join = params[:join].presence || "and"
    @conditions = filter_conditions
    @lots = filtered_lots
    @filter_config = ProductionLotFilter.js_config
  end

  def export
    lots = filtered_lots
    fname = "ar_unit_tracking_#{Time.current.strftime('%Y%m%d')}"

    case params[:format].to_s
    when "csv"
      send_data to_csv(full_table(lots)), filename: "#{fname}.csv", type: "text/csv"
    when "xlsx"
      send_data to_xlsx(full_table(lots)), filename: "#{fname}.xlsx",
                type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    when "pdf"
      send_data to_pdf(lots), filename: "#{fname}.pdf", type: "application/pdf"
    else
      redirect_to records_path, alert: "Unknown export format."
    end
  end

  private

  def require_section
    redirect_to dashboard_path, alert: "You don't have access to Tracking." unless current_user.can_see?("records")
  end

  def filtered_lots
    join = params[:join].presence || "and"
    base = ProductionLot.includes(lot_attachments: { file_attachment: :blob }).order(:created_at)
    ProductionLotFilter.new(filter_conditions, join).apply(base)
  end

  def filter_conditions
    raw = params[:f]
    return [] if raw.blank?
    list = raw.respond_to?(:values) ? raw.values : raw
    Array(list).map do |c|
      h = c.respond_to?(:to_unsafe_h) ? c.to_unsafe_h : c
      { "field" => h["field"], "operator" => h["operator"], "value" => h["value"], "value2" => h["value2"] }
    end.select { |c| c["field"].present? && c["operator"].present? }
  end

  # ---- export helpers ----
  def fmt_date(d) = d ? d.strftime("%d %b %Y") : ""
  def yn(b) = b ? "Yes" : "No"

  # Full column set for CSV / Excel
  def full_table(lots)
    headers = ["Design", "Laat #", "EMB Name", "Total Suits",
               "EMB Sent", "EMB Sent Qty", "EMB In", "EMB Recv Qty", "EMB Paid",
               "Production", "CutWork Sent", "CW Sent Qty", "CW Recv Qty", "CW Paid",
               "OverLock Sent", "OL Sent Qty", "OL Recv Qty", "OL Paid",
               "HM Sent Qty", "HM Recv Qty", "HM Return", "HM Paid",
               "Press", "Out", "Progress %"]
    rows = lots.map do |l|
      [l.design, l.laat_number, l.emb_name, l.total_suit,
       fmt_date(l.emb_sent_date), l.emb_sent_qty, fmt_date(l.emb_received_date), l.emb_received_qty, yn(l.emb_paid),
       fmt_date(l.production_date), fmt_date(l.cutwork_sent_date), l.cutwork_sent_qty, l.cutwork_received_qty, yn(l.cutwork_paid),
       fmt_date(l.overlock_sent_date), l.overlock_sent_qty, l.overlock_received_qty, yn(l.overlock_paid),
       l.handmade_sent_qty, l.handmade_received_qty, fmt_date(l.handmade_return_date), yn(l.handmade_paid),
       fmt_date(l.press_date), fmt_date(l.out_date), "#{l.progress_pct}%"]
    end
    [headers] + rows
  end

  def to_csv(rows)
    CSV.generate { |csv| rows.each { |r| csv << r } }
  end

  def to_xlsx(rows)
    require "axlsx"
    pkg = Axlsx::Package.new
    pkg.workbook.add_worksheet(name: "Tracking") do |sheet|
      header = sheet.styles.add_style(b: true, bg_color: "1F2D3D", fg_color: "FFFFFF")
      sheet.add_row ["AR-Unit — Production Tracking"]
      sheet.add_row rows.first, style: header
      rows.drop(1).each { |r| sheet.add_row r }
    end
    pkg.to_stream.read
  end

  # Full-data landscape PDF — every field (except attachments), abbreviated headers
  # + short dates + shrink-to-fit so all 25 columns fit the page.
  def to_pdf(lots)
    require "prawn"
    require "prawn/table"
    sd = ->(d) { d ? d.strftime("%d/%m/%y") : "—" }
    yn2 = ->(b) { b ? "Y" : "N" }
    headers = ["Design", "Laat", "EMB", "Suits",
               "EMB Sent", "EMB Q", "EMB In", "EMB Rcv", "EMB Pd",
               "Prod", "CW Sent", "CW Q", "CW Rcv", "CW Pd",
               "OL Sent", "OL Q", "OL Rcv", "OL Pd",
               "HM Q", "HM Rcv", "HM Ret", "HM Pd", "Press", "Out", "%"]
    rows = lots.map do |l|
      [l.design, l.laat_number, l.emb_name, l.total_suit,
       sd.(l.emb_sent_date), l.emb_sent_qty, sd.(l.emb_received_date), l.emb_received_qty, yn2.(l.emb_paid),
       sd.(l.production_date), sd.(l.cutwork_sent_date), l.cutwork_sent_qty, l.cutwork_received_qty, yn2.(l.cutwork_paid),
       sd.(l.overlock_sent_date), l.overlock_sent_qty, l.overlock_received_qty, yn2.(l.overlock_paid),
       l.handmade_sent_qty, l.handmade_received_qty, sd.(l.handmade_return_date), yn2.(l.handmade_paid),
       sd.(l.press_date), sd.(l.out_date), "#{l.progress_pct}%"].map { |v| v.nil? ? "—" : v.to_s }
    end

    pdf = Prawn::Document.new(page_size: "A4", page_layout: :landscape, margin: 16)
    pdf.fill_color "1F2D3D"
    pdf.text "AR-Unit Factory — Production Tracking", size: 13, style: :bold
    pdf.fill_color "000000"
    pdf.text "Generated #{Time.current.strftime('%d %b %Y, %H:%M')} · #{lots.size} lots · all fields", size: 7, color: "888888"
    pdf.move_down 8
    pdf.table([headers] + rows, header: true, width: pdf.bounds.width,
              cell_style: { size: 5.5, padding: 2, overflow: :shrink_to_fit, min_font_size: 4 }) do
      row(0).background_color = "1F2D3D"
      row(0).text_color = "FFFFFF"
      row(0).font_style = :bold
      cells.borders = [:bottom]
      cells.border_color = "DDDDDD"
    end
    pdf.render
  end
end
