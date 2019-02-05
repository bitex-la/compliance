class CreateTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :tasks do |t|
      t.references :workflow, foreign_key: true
      t.string :aasm_state
      t.integer :index

      t.timestamps
    end
  end
end
