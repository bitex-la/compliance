class CreateRelationships < ActiveRecord::Migration[5.1]
  
  def up   
    create_table :relationships do |t|
      t.references :relationship_seed, foreign_key: true
      t.references :person, foreign_key: { to_table: :people }
      t.references :related_person, foreign_key: { to_table: :people }
      t.string :kind

      t.timestamps
    end

    remove_column :relationship_seeds, :person_from_id
    rename_column :relationship_seeds, :person_to_id, :related_person_id
    
  end

  def down
    drop_table :relationships
    add_column :relationship_seeds, :person_from_id, :integer
    rename_column :relationship_seeds, :related_person_id, :person_to_id
  end
end
