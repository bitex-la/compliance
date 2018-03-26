class AddFieldsToArgentinaInvoiceDetail < ActiveRecord::Migration[5.1]
  def change
    add_column :argentina_invoicing_details, :tax_id_type, :string
    add_column :argentina_invoicing_details, :receipt_type, :string
    add_column :argentina_invoicing_details, :name, :string
    add_column :argentina_invoicing_details, :address, :string
    add_column :argentina_invoicing_details, :country, :string
  end
end
