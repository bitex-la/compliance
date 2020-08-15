class AddAutoCreatedToAffinitySeed < ActiveRecord::Migration[5.2]
  def change
    add_column :affinity_seeds, :auto_created, :boolean, default: false
  end
end
