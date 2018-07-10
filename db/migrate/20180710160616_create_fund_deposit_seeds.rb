class CreateFundDepositSeeds < ActiveRecord::Migration[5.1]
  def change
    create_table :fund_deposit_seeds do |t|
      t.decimal :amount
      t.integer :currency_id
      t.integer :deposit_method_id
      t.references :issue, foreign_key: true

      t.timestamps
    end
  end
end
