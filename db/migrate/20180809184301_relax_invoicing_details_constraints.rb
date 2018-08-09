class RelaxInvoicingDetailsConstraints < ActiveRecord::Migration[5.1]
  def change
    change_column :argentina_invoicing_detail_seeds, :tax_id, :string, null: true
    change_column :argentina_invoicing_details, :tax_id, :string, null: true
    change_column :argentina_invoicing_detail_seeds, :vat_status_id, :string, null: true
    change_column :argentina_invoicing_details, :vat_status_id, :string, null: true
  end
end
