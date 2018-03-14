class AddForeignsToChileInvoicing < ActiveRecord::Migration[5.1]
  def change
    add_reference :chile_invoicing_detail_seeds, :replaces, foreign_key: { to_table: :chile_invoicing_details }
    add_reference :chile_invoicing_detail_seeds, :fruit, foreign_key: { to_table: :chile_invoicing_details }
    add_reference :chile_invoicing_details, :replaced_by, foreign_key: { to_table: :chile_invoicing_details }
  end
end
