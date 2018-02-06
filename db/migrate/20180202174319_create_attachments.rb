class CreateAttachments < ActiveRecord::Migration[5.1]
  def change
    create_table :attachments do |t|
      t.references :person, foreign_key: true
      t.integer :seed_to_id
      t.string :seed_to_type

      t.timestamps
    end
  end
end
