class CreatePhones < ActiveRecord::Migration[5.1]
  def change
    create_table :phones do |t|
      t.string :number
      t.string :kind
      t.string :country
      t.boolean :has_whatsapp
      t.boolean :has_telegram
      t.text :note
      t.references :person, foreign_key: true

      t.timestamps
    end
  end
end
