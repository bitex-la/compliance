class CreateInvoicingDetailArgentinas < ActiveRecord::Migration[5.1]
  def change
    create_table :argentina_invoicing_details do |t|
      t.string :vat_status_id
      t.string :tax_id
      t.references :issue, foreign_key: true
      t.references :person, foreign_key: true

      t.timestamps
    end
  end
end
