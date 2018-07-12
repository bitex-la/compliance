class AddExternalIdToFundDeposits < ActiveRecord::Migration[5.1]
  def change
    add_column :fund_deposit_seeds, :external_id, :integer
    add_column :fund_deposits, :external_id, :integer
  end
end
