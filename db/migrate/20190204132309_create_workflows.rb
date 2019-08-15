class CreateWorkflows < ActiveRecord::Migration[5.1]
  def change
    create_table :workflows do |t|
      t.integer :scope
      t.string :aasm_state
      t.integer :workflow_kind_id

      t.timestamps
    end
  end
end
