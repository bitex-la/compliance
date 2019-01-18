class AddPrivateColumnToNotes < ActiveRecord::Migration[5.1]
  def change
    add_column :notes, :private, :boolean
    add_column :note_seeds, :private, :boolean

    #TODO: Migrate current notes and decide whether they are private or public
  end
end
