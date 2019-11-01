class AddPublicToNotes < ActiveRecord::Migration[5.2]
  def change
    add_column :note_seeds, :public, :bool, null: false, default: false
    add_column :notes, :public, :bool, null: false, default: false
  end
end
