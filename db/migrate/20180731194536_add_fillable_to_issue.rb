class AddFillableToIssue < ActiveRecord::Migration[5.1]
  def change
    add_column :issues, :fill_with_previous_info, :boolean, default: false
  end
end
