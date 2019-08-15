class AddOutputToTask < ActiveRecord::Migration[5.1]
  def change
    add_column :tasks, :output, :text
  end
end
