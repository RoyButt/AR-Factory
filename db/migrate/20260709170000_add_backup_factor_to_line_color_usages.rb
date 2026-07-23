class AddBackupFactorToLineColorUsages < ActiveRecord::Migration[7.0]
  def change
    add_column :line_color_usages, :backup_factor, :decimal, precision: 4, scale: 2, default: 1.0
  end
end
