class CreateTaskTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :task_types do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
