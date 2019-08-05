Dir[Rails.root.join("app/serializers/**/*.rb")].each {|f| require f}
class AddShowAfterToIssues < ActiveRecord::Migration[5.1]
  def up
    add_column :issues, :defer_until, :date

    execute "UPDATE issues set defer_until = DATE(created_at)"

    change_column_null :issues, :defer_until, false
  end

  def down
    remove_column :issues, :defer_until
  end
end
