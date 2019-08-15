class ChangeFundDepositsExternalId < ActiveRecord::Migration[5.1]
  def up
    change_column :fund_deposits, :external_id, :string 
  end

  def down
    change_column :fund_deposits, :external_id, :integer 
  end
end
