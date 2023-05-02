class AddNoteTypeToNote < ActiveRecord::Migration[5.2]
  def change
    add_column :notes, :note_type, :integer, :default => 0, null: false
  end
end
