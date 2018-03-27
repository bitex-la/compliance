class RenameRelationshipTable < ActiveRecord::Migration[5.1]
  def change
    rename_table :relationships, :affinities
    rename_table :relationship_seeds, :affinity_seeds
    rename_column :affinities, :relationship_seed_id, :affinity_seed_id
  end
end
