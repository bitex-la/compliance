class AddCountryDepositDateToFundDeposit < ActiveRecord::Migration[5.2]
  def change
    add_column :fund_deposits, :deposit_date, :date
    add_column :fund_deposits, :country, :string
  end
end
