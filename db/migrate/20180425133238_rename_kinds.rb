class RenameKinds < ActiveRecord::Migration[5.1]
  def change
    # Argentina invoicing details
    rename_column :argentina_invoicing_detail_seeds, :tax_id_type, :tax_id_kind_id
    rename_column :argentina_invoicing_details, :tax_id_type, :tax_id_kind_id
    change_column :argentina_invoicing_detail_seeds, :tax_id_kind_id, :integer
    change_column :argentina_invoicing_details, :tax_id_kind_id, :integer
    rename_column :argentina_invoicing_detail_seeds, :receipt_type, :receipt_kind_id
    rename_column :argentina_invoicing_details, :receipt_type, :receipt_kind_id
    change_column :argentina_invoicing_detail_seeds, :receipt_kind_id, :integer
    change_column :argentina_invoicing_details, :receipt_kind_id, :integer

    # Chile invoicing details
    change_column :chile_invoicing_detail_seeds, :vat_status_id, :integer
    change_column :chile_invoicing_details, :vat_status_id, :integer

    # Identifications
    rename_column :identification_seeds, :kind, :identification_kind_id
    rename_column :identifications, :kind, :identification_kind_id
    change_column :identification_seeds, :identification_kind_id, :integer
    change_column :identifications, :identification_kind_id, :integer

    # Phones
    rename_column :phone_seeds, :kind, :phone_kind_id
    rename_column :phones, :kind, :phone_kind_id
    change_column :phone_seeds, :phone_kind_id, :integer
    change_column :phones, :phone_kind_id, :integer

    # Emails
    rename_column :email_seeds, :kind, :email_kind_id
    rename_column :emails, :kind, :email_kind_id
    change_column :email_seeds, :email_kind_id, :integer
    change_column :emails, :email_kind_id, :integer

    # Affinities
    rename_column :affinity_seeds, :kind, :affinity_kind_id
    rename_column :affinities, :kind, :affinity_kind_id
    change_column :affinity_seeds, :affinity_kind_id, :integer
    change_column :affinities, :affinity_kind_id, :integer
  end
end
