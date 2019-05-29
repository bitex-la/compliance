class AddShowAfterToIssues < ActiveRecord::Migration[5.1]
  def change
    add_column :issues, :show_after, :date
  end
end
