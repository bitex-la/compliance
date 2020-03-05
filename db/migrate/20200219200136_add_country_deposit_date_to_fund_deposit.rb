class AddCountryDepositDateToFundDeposit < ActiveRecord::Migration[5.2]
  def change
    add_column :fund_deposits, :deposit_date, :datetime
    add_column :fund_deposits, :country, :string
  end
end
