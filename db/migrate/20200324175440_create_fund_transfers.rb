class CreateFundTransfers < ActiveRecord::Migration[5.2]
  def change
    create_table :fund_transfers do |t|
      t.references :source_person_id, foreign_key: true, null: false
      t.references :target_person_id, foreign_key: true, null: false
      t.decimal :amount, null: false
      t.datetime :transfer_date
      t.decimal :exchange_rate_adjusted_amount,
                precision: 20,
                scale: 8,
                null: false
      t.integer :currency_id, null: false

      t.timestamps
    end
  end
end
