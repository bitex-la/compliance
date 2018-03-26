class AddFieldsToArgentinaInvoiceDetailSeeds < ActiveRecord::Migration[5.1]
  def change
    add_column :argentina_invoicing_detail_seeds, :tax_id_type, :string
    add_column :argentina_invoicing_detail_seeds, :receipt_type, :string
    add_column :argentina_invoicing_detail_seeds, :name, :string
    add_column :argentina_invoicing_detail_seeds, :address, :string
    add_column :argentina_invoicing_detail_seeds, :country, :string
  end
end
