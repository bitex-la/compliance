class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t|
      t.integer :commentable_id
      t.string :commentable_type
      t.integer :author_id
      t.string :title
      t.text :meta
      t.text :body

      t.timestamps
    end
  end
end
