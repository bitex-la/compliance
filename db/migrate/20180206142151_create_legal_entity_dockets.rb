class CreateLegalEntityDockets < ActiveRecord::Migration[5.1]
  def change
    create_table :legal_entity_dockets do |t|
      t.string :industry
      t.text :business_description
      t.string :country
      t.string :commercial_name
      t.string :legal_name
      t.references :issue, foreign_key: true
      t.references :person, foreign_key: true

      t.timestamps
    end
  end
end
