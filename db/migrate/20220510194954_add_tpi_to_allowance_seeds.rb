class AddTpiToAllowanceSeeds < ActiveRecord::Migration[5.2]
  def change
    add_column :allowance_seeds, :tpi, :integer
  end
end
