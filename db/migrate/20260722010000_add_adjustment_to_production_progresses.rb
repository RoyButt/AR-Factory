class AddAdjustmentToProductionProgresses < ActiveRecord::Migration[7.0]
  def change
    add_column :production_progresses, :adjustment, :decimal, precision: 10, scale: 2, default: 0, null: false
  end
end
