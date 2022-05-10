class AddIptToPeople < ActiveRecord::Migration[5.2]
  def change
    add_column :people, :ipt, :integer, :default => 0
  end
end
