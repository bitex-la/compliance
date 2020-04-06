class AddPersoCountryIndexToFunding < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  def change
    %i(fund_deposits fund_withdrawals).each do |entity|
      add_index entity, [:person_id, :country], :algorithm => :copy
    end
  end
end
