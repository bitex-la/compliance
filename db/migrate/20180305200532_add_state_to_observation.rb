class AddStateToObservation < ActiveRecord::Migration[5.1]
  def change
    add_column :observations, :aasm_state, :string
  end
end
