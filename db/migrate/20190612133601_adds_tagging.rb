class AddsTagging < ActiveRecord::Migration[5.2]
  def change
    create_table :tags do |t|
      t.string :name, limit: 30, null: false
      t.integer "tag_type", null: false
      t.timestamps
    end

    add_index :tags, [:tag_type, :name], unique: true
  end
end
