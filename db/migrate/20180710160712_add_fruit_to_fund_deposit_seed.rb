class AddFruitToFundDepositSeed < ActiveRecord::Migration[5.1]
  def change
    add_reference :fund_deposit_seeds, :fruit, foreign_key: { to_table: :fund_deposits }
  end
end
