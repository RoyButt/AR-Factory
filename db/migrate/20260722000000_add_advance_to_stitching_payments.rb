class AddAdvanceToStitchingPayments < ActiveRecord::Migration[7.0]
  def change
    add_column :stitching_payments, :advance, :boolean, default: false, null: false
  end
end
