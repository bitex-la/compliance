class CreateNaturalDockets < ActiveRecord::Migration[5.1]
  def change
    create_table :natural_dockets do |t|
      t.string :first_name
      t.string :last_name
      t.date :birth_date
      t.string :nationality
      t.string :gender
      t.string :marital_status
      t.references :issue, foreign_key: true
      t.references :person, foreign_key: true

      t.timestamps
    end
  end
end
