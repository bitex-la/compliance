class CreateFundDeposits < ActiveRecord::Migration[5.1]
  def change
    create_table :fund_deposits do |t|
      t.decimal :amount
      t.integer :currency_id
      t.integer :deposit_method_id
      t.references :person, foreign_key: true
      t.references :issue, foreign_key: true

      t.timestamps
    end
  end
end
