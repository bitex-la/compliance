class RenameKindInAllowances < ActiveRecord::Migration[5.1]
  def change
    remove_column :allowances, :kind
    add_column :allowances, :kind_id, :integer

    remove_column :allowance_seeds, :kind
    add_column :allowance_seeds, :kind_id, :integer
  end
end
