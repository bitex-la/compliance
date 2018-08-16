class RemoveReferencesFromFundDeposit < ActiveRecord::Migration[5.1]
  def change
    drop_table :fund_deposit_seeds
    remove_reference :fund_deposits, :issue, index: true, foreign_key: true
    remove_foreign_key :fund_deposits, column: :replaced_by_id
  end
end
