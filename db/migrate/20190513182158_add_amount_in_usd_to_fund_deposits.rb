class AddAmountInUsdToFundDeposits < ActiveRecord::Migration[5.1]
  def change
    reversible{|dir| dir.up{ FundDeposit.delete_all } }
    %i(amount currency_id deposit_method_id person_id).each do |column|
      change_column_null :fund_deposits, column, false
    end
    add_column :fund_deposits, :exchange_rate_adjusted_amount, 
      :decimal, precision: 20, scale: 8, null: false

    add_column :people, :regularity_id, :integer, null:false,
      default: PersonRegularity.casual.id

  end
end
