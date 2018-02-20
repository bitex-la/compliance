class RemoveToFromInRelationships < ActiveRecord::Migration[5.1]
  def change
    remove_column :relationship_seeds, :from
    remove_column :relationship_seeds, :to
    add_reference :relationship_seeds, :person_to, foreign_key: { to_table: :people }
    add_reference :relationship_seeds, :person_from, foreign_key: { to_table: :people }
  end
end
