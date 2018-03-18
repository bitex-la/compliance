class CreateNoteSeeds < ActiveRecord::Migration[5.1]
  def change
    create_table :note_seeds do |t|
      t.string :title
      t.text :body
      t.references :issue, foreign_key: true

      t.timestamps
    end
  end
end
