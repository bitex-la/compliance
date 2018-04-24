class RenameQuotasToAllowances < ActiveRecord::Migration[5.1]
  def change
    rename_table :quota, :allowances
    rename_table :quota_seeds, :allowance_seeds
    rename_column :allowance_seeds, :quota_id, :allowance_id
  end
end
