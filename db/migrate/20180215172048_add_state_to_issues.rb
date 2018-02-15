class AddStateToIssues < ActiveRecord::Migration[5.1]
  def self.up
    add_column :issues, :aasm_state, :string
    Issue.update_all(aasm_state: 'new')
  end

  def self.down
    remove_column :issues, :state
  end
end
