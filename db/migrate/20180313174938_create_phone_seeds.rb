class CreatePhoneSeeds < ActiveRecord::Migration[5.1]
  def change
    create_table :phone_seeds do |t|
      t.string :number
      t.string :kind
      t.string :country
      t.boolean :has_whatsapp
      t.boolean :has_telegram
      t.text :note
      t.references :issue, foreign_key: true

      t.timestamps
    end
  end
end
