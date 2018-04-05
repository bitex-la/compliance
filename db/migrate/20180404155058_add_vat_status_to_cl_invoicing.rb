class AddVatStatusToClInvoicing < ActiveRecord::Migration[5.1]
  def change
    add_column :chile_invoicing_detail_seeds, :vat_status_id, :string
    add_column :chile_invoicing_details, :vat_status_id, :string
  end
end
