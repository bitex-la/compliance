class CreateDomiciles < ActiveRecord::Migration[5.1]
  def change
    create_table :domiciles do |t|
      t.string :country
      t.string :state
      t.string :city
      t.string :street_address
      t.string :street_number
      t.string :postal_code
      t.string :floor
      t.string :apartment
      t.references :issue, foreign_key: true
      t.references :person, foreign_key: true

      t.timestamps
    end
  end
end
