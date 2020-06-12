class AddContraintsToFundDeposits < ActiveRecord::Migration[5.2]
  def change
    change_column_null :fund_deposits, :deposit_date, false
    change_column_null :fund_deposits, :country, false
    change_column_null :fund_deposits, :external_id, false
  end
end
