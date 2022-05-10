class AddIptToAllowanceSeeds < ActiveRecord::Migration[5.2]
  def change
    add_column :allowance_seeds, :ipt, :integer, :default => 0
  end
end
