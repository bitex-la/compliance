class AddIptToAllowances < ActiveRecord::Migration[5.2]
  def change
    add_column :allowances, :ipt, :integer, :default => 0
  end
end
