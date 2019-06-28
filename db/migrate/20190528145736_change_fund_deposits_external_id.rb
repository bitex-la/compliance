class ChangeFundDepositsExternalId < ActiveRecord::Migration[5.1]
  def change
    change_column :fund_deposits, :external_id, :string 
  end
end
