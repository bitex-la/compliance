class CreateIdentificationSeeds < ActiveRecord::Migration[5.1]
  def change
    create_table :identification_seeds do |t|
      t.references :issue, foreign_key: true
      t.string :kind
      t.string :number
      t.string :issuer

      t.timestamps
    end
  end
end
