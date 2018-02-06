class CreateRelationshipSeeds < ActiveRecord::Migration[5.1]
  def change
    create_table :relationship_seeds do |t|
      t.references :issue, foreign_key: true
      t.string :to
      t.string :from
      t.string :kind

      t.timestamps
    end
  end
end
