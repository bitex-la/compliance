class RenameNameInArgetinaInvoicing < ActiveRecord::Migration[5.1]
  def change
    rename_column :argentina_invoicing_detail_seeds, :name, :full_name
    rename_column :argentina_invoicing_details, :name, :full_name
  end
end
