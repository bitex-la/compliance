class AddFruitReferenceToAttachments < ActiveRecord::Migration[5.1]
  def change
    rename_column :attachments, :attached_to_id, :attached_to_seed_id
    rename_column :attachments, :attached_to_type, :attached_to_seed_type
    add_column :attachments, :attached_to_fruit_id, :integer
    add_column :attachments, :attached_to_fruit_type, :string
  end
end
