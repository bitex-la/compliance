class DropTaskType < ActiveRecord::Migration[5.1]
  def change
    remove_foreign_key :tasks, :task_types
    remove_column :tasks, :task_type_id
    drop_table :task_types
  end
end
