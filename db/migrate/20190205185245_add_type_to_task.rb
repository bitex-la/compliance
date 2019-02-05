class AddTypeToTask < ActiveRecord::Migration[5.1]
  def change
    add_reference :tasks, :task_type, foreign_key: true
  end
end
