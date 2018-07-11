class AddDecimalToFundDeposit < ActiveRecord::Migration[5.1]
  def change
    change_column :fund_deposits, :amount, :decimal, precision: 20, scale: 8
    change_column :fund_deposit_seeds, :amount, :decimal, precision: 20, scale: 8
  end
end
