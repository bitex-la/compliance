class AddFundingToFundingSeed < ActiveRecord::Migration[5.1]
  def change
    add_reference :funding_seeds, :funding, foreign_key: { to_table: :fundings }
  end
end
