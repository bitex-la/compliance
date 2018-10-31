class AddAasmToPeople < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :aasm_state, :string
  end
end
