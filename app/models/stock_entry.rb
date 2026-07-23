class StockEntry < ApplicationRecord
  validates :product_name, presence: true

  def month
    stock_date&.strftime("%B %Y")
  end
end
