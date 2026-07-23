require "csv"

class AnalyticsController < ApplicationController
  before_action :require_login
  before_action :require_section

  def index
    @data = AnalyticsData.new(filter_params)
  end

  def export
    @data = AnalyticsData.new(filter_params)
    fname = "ar_unit_#{@data.dataset}_#{Time.current.strftime('%Y%m%d')}"

    case params[:format].to_s
    when "csv"
      send_data to_csv(@data.export_rows),
                filename: "#{fname}.csv", type: "text/csv"
    when "xlsx"
      send_data to_xlsx(@data),
                filename: "#{fname}.xlsx",
                type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    when "pdf"
      send_data to_pdf(@data),
                filename: "#{fname}.pdf", type: "application/pdf"
    else
      redirect_to analytics_path, alert: "Unknown export format."
    end
  end

  private

  def filter_params
    params.permit(:from, :to, :dataset)
  end

  def require_section
    redirect_to dashboard_path, alert: "You don't have access to Analytics." unless current_user.can_see?("analytics")
  end

  def to_csv(rows)
    CSV.generate { |csv| rows.each { |r| csv << r } }
  end

  def to_xlsx(data)
    require "axlsx"
    pkg = Axlsx::Package.new
    wb  = pkg.workbook
    rows = data.export_rows
    wb.add_worksheet(name: data.export_title.first(31)) do |sheet|
      header = sheet.styles.add_style(b: true, bg_color: "1F2D3D", fg_color: "FFFFFF")
      sheet.add_row ["AR-Unit — #{data.export_title}"]
      sheet.add_row rows.first, style: header
      rows.drop(1).each { |r| sheet.add_row r }
    end
    pkg.to_stream.read
  end

  def to_pdf(data)
    require "prawn"
    require "prawn/table"
    rows = data.export_rows
    pdf = Prawn::Document.new(page_size: "A4", margin: 40)
    pdf.fill_color "1F2D3D"
    pdf.text "AR-Unit Factory Management System", size: 18, style: :bold
    pdf.fill_color "000000"
    pdf.text data.export_title, size: 13
    pdf.text "Generated: #{Time.current.strftime('%d %b %Y, %H:%M')}", size: 9, color: "888888"
    pdf.move_down 14
    pdf.table(rows, header: true, width: pdf.bounds.width) do
      row(0).background_color = "1F2D3D"
      row(0).text_color = "FFFFFF"
      row(0).font_style = :bold
      cells.padding = 7
      cells.borders = [:bottom]
      cells.border_color = "DDDDDD"
    end
    pdf.render
  end
end
