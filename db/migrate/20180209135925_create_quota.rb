class CreateQuota < ActiveRecord::Migration[5.1]
  def change
    create_table :quota do |t|
      t.decimal :weight
      t.decimal :amount
      t.string :kind
      t.references :issue, foreign_key: true
      t.references :person, foreign_key: true

      t.timestamps
    end
  end
end
