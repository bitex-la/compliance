class AddsTagging < ActiveRecord::Migration[5.2]
  def change
    create_table :tags do |t|
      t.string :name, limit: 30, null: false
      t.integer "tag_type", null: false
      t.timestamps
      t.index [:tag_type, :name], unique: true
    end

    create_table :person_taggings do |t|
      t.belongs_to :person, index: true , null: false, foreign_key: true
      t.belongs_to :tag, index: true , null: false, foreign_key: true
      t.timestamps
      t.index [:person_id, :tag_id], unique: true
    end

    create_table :issue_taggings do |t|
      t.belongs_to :issue, index: true, null: false, foreign_key: true
      t.belongs_to :tag, index: true, null: false, foreign_key: true
      t.timestamps
      t.index [:issue_id, :tag_id], unique: true
    end
  end
end
