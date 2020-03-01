class CreateFundWithdrawals < ActiveRecord::Migration[5.2]
  def change
    create_table :fund_withdrawals do |t|
      t.references :person, foreign_key: true, null: false
      t.decimal :amount, precision: 20, scale: 8, null: false
      t.integer :currency_id, null: false
      t.decimal :exchange_rate_adjusted_amount,
                precision: 20,
                scale: 8,
                null: false
      t.datetime :withdrawal_date
      t.string :country

      t.timestamps
    end
  end
end
