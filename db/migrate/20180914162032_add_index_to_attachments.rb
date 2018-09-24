class AddIndexToAttachments < ActiveRecord::Migration[5.1]
  def change
    add_index :attachments, [ :attached_to_seed_type, :attached_to_seed_id], name: "attached_to_seed"
    add_index :attachments, [ :attached_to_fruit_type, :attached_to_fruit_id], name: "attached_to_fruit"
    add_index :attachments, :attached_to_seed_type
    add_index :attachments, :attached_to_fruit_type
  end
end
