class AddStateIndexToIssues < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!
  def change
    add_index :issues, :aasm_state, :algorithm => :copy
  end
end
