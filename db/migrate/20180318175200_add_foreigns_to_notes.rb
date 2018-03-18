class AddForeignsToNotes < ActiveRecord::Migration[5.1]
  def change
    add_reference :note_seeds, :replaces, foreign_key: {to_table: :notes}
    add_reference :note_seeds, :fruit, foreign_key: {to_table: :notes}
    add_reference :notes, :replaced_by, foreign_key: {to_table: :notes} 
  end
end
