class AddsAasmStateToPeople < ActiveRecord::Migration[5.2]
  def change
    add_column :people, :aasm_state, :string, null: false, default: :new
    add_index :people, :aasm_state, :algorithm => :copy

    Person.where('enabled = 1')
      .update_all(aasm_state: :enabled)

    Person.where('enabled = 0')
      .update_all(aasm_state: :disabled)
  end
end
