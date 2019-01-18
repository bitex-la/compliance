class AddPrivateColumnToIssues < ActiveRecord::Migration[5.1]
  def change
    add_column :issues, :private, :boolean, default: false
  end
end
