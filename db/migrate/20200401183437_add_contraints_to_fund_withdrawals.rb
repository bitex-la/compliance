class AddContraintsToFundWithdrawals < ActiveRecord::Migration[5.2]
  def change
    change_column_null :fund_withdrawals, :withdrawal_date, false
    change_column_null :fund_withdrawals, :country, false
    change_column_null :fund_withdrawals, :external_id, false
  end
end
