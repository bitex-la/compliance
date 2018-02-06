class CreateIdentifications < ActiveRecord::Migration[5.1]
  def change
    create_table :identifications do |t|
      t.string :number
      t.string :kind
      t.string :issuer
      t.references :issue, foreign_key: true
      t.references :person, foreign_key: true

      t.timestamps
    end
  end
end
