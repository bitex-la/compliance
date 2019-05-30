Dir[Rails.root.join("app/serializers/**/*.rb")].each {|f| require f}
class AddShowAfterToIssues < ActiveRecord::Migration[5.1]
  def up
    add_column :issues, :show_after, :date

    Issue.all.each { |i| i.update_attribute(:show_after, i.created_at) }

    change_column_null :issues, :show_after, false
  end

  def down
    remove_column :issues, :show_after
  end
end
