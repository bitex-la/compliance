class AddAutoCreatedToAffinity < ActiveRecord::Migration[5.2]
  def change
    add_column :affinities, :auto_created, :boolean, default: false
  end
end
