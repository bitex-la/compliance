class AddPersonFields < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :enabled, :boolean, null: false, default: false
    add_column :people, :risk, :integer
  end
end
