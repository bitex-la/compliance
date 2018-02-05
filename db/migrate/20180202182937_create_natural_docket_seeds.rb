class CreateNaturalDocketSeeds < ActiveRecord::Migration[5.1]
  def change
    create_table :natural_docket_seeds do |t|
      t.references :issue, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.date :birth_date
      t.string :nationality
      t.string :gender
      t.string :marital_status

      t.timestamps
    end
  end
end
