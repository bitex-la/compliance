class AddFlagToSeeds < ActiveRecord::Migration[5.1]
  def change
    add_column :allowance_seeds, :copy_attachments, :boolean       
    add_column :argentina_invoicing_detail_seeds, :copy_attachments, :boolean 
    add_column :chile_invoicing_detail_seeds, :copy_attachments, :boolean 
    add_column :domicile_seeds, :copy_attachments, :boolean 
    add_column :email_seeds, :copy_attachments, :boolean 
    add_column :identification_seeds, :copy_attachments, :boolean 
    add_column :legal_entity_docket_seeds, :copy_attachments, :boolean 
    add_column :natural_docket_seeds, :copy_attachments, :boolean 
    add_column :phone_seeds, :copy_attachments, :boolean 
    add_column :relationship_seeds, :copy_attachments, :boolean 
  end
end
