class AddExpectedInvestmentToNaturalDockets < ActiveRecord::Migration[5.2]
  def change
    add_column :natural_dockets, :expected_investment, :decimal, precision: 20, scale: 8
    add_column :natural_docket_seeds, :expected_investment, :decimal, precision: 20, scale: 8
  end
end
