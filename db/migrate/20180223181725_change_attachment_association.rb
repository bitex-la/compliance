class ChangeAttachmentAssociation < ActiveRecord::Migration[5.1]
  def change
    rename_column :attachments, :seed_to_id, :attached_to_id
    rename_column :attachments, :seed_to_type, :attached_to_type
  end
end
