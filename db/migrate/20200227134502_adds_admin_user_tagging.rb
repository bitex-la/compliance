class AddsAdminUserTagging < ActiveRecord::Migration[5.2]
  def change
    create_table :admin_user_taggings do |t|
      t.belongs_to :admin_user, index: true , null: false, foreign_key: true
      t.belongs_to :tag, index: true , null: false, foreign_key: true
      t.timestamps
      t.index [:admin_user_id, :tag_id], unique: true
    end
  end
end
