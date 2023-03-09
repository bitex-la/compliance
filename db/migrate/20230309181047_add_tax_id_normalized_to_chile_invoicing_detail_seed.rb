class AddTaxIdNormalizedToChileInvoicingDetailSeed < ActiveRecord::Migration[5.2]
  def change
    add_column :chile_invoicing_detail_seeds, :tax_id_normalized, :string
    add_index :chile_invoicing_detail_seeds, :tax_id_normalized, unique: false
  end
end
