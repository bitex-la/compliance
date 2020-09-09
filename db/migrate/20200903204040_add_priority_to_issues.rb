class AddPriorityToIssues < ActiveRecord::Migration[5.2]
  def change
    add_column :issues, :priority, :integer, null: false, default: 0
    add_index :issues, [:priority, :id]
  end
end
