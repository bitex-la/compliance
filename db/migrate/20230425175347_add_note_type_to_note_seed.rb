class AddNoteTypeToNoteSeed < ActiveRecord::Migration[5.2]
  def change
    add_column :note_seeds, :note_type, :integer, :default => 0, null: false
  end
end
