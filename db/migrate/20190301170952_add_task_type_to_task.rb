class AddTaskTypeToTask < ActiveRecord::Migration[5.1]
  def change
    add_column :tasks, :task_type, :string
  end
end
