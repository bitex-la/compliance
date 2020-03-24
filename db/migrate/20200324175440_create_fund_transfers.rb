class CreateFundTransfers < ActiveRecord::Migration[5.2]
  def change
    create_table :fund_transfers do |t|
      t.bigint :source_person_id
      t.bigint :target_person_id
      t.decimal :amount
      t.datetime :transfer_date
      t.decimal :exchange_rate_adjusted_amount
      t.integer :currency_id

      t.timestamps
    end
  end
end
