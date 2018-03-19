class CreateNotes < ActiveRecord::Migration[5.1]
  def change
    create_table :notes do |t|
      t.string :title
      t.text :body
      t.references :issue, foreign_key: true
      t.references :person, foreign_key: true

      t.timestamps
    end
  end
end
