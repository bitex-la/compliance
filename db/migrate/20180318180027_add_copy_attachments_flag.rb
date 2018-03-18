class AddCopyAttachmentsFlag < ActiveRecord::Migration[5.1]
  def change
    add_column :note_seeds, :copy_attachments, :boolean
  end
end
