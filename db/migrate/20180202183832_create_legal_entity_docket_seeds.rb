class CreateLegalEntityDocketSeeds < ActiveRecord::Migration[5.1]
  def change
    create_table :legal_entity_docket_seeds do |t|
      t.references :issue, foreign_key: true
      t.string :industry
      t.text :business_description
      t.string :country
      t.string :commercial_name
      t.string :legal_name

      t.timestamps
    end
  end
end
