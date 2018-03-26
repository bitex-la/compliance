class AddNullConstraints < ActiveRecord::Migration[5.1]
  def change
    change_column_null :phones, :has_whatsapp, false
    change_column_null :phones, :has_telegram, false
    change_column_null :phone_seeds, :has_whatsapp, false
    change_column_null :phone_seeds, :has_telegram, false
    change_column_null :argentina_invoicing_details, :vat_status_id, false
    change_column_null :argentina_invoicing_details, :tax_id, false
    change_column_null :argentina_invoicing_details, :tax_id_type, false
    change_column_null :argentina_invoicing_details, :receipt_type, false
    change_column_null :argentina_invoicing_details, :name, false
    change_column_null :argentina_invoicing_details, :address, false
    change_column_null :argentina_invoicing_details, :country, false
    change_column_null :argentina_invoicing_detail_seeds, :vat_status_id, false
    change_column_null :argentina_invoicing_detail_seeds, :tax_id, false
    change_column_null :argentina_invoicing_detail_seeds, :tax_id_type, false
    change_column_null :argentina_invoicing_detail_seeds, :receipt_type, false
    change_column_null :argentina_invoicing_detail_seeds, :name, false
    change_column_null :argentina_invoicing_detail_seeds, :address, false
    change_column_null :argentina_invoicing_detail_seeds, :country, false
  end
end
