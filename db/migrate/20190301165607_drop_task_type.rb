class DropTaskType < ActiveRecord::Migration[5.1]
  def change
    remove_foreign_key :tasks, :task_types
    drop_table :task_types
  end
end
