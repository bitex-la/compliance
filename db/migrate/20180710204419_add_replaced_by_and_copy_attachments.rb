class AddReplacedByAndCopyAttachments < ActiveRecord::Migration[5.1]
  def change
    add_column :fund_deposit_seeds, :replaces_id, :integer
    add_column :fund_deposit_seeds, :copy_attachments, :boolean
    add_reference :fund_deposits, :replaced_by, foreign_key: {to_table: :fund_deposits}
  end
end
