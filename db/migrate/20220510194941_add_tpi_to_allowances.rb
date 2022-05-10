class AddTpiToAllowances < ActiveRecord::Migration[5.2]
  def change
    add_column :allowances, :tpi, :integer
  end
end
