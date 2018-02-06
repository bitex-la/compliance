class CreateFundings < ActiveRecord::Migration[5.1]
  def change
    create_table :fundings do |t|
      t.decimal :amount
      t.string :kind
      t.references :issue, foreign_key: true
      t.references :person, foreign_key: true

      t.timestamps
    end
  end
end
