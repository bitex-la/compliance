class CreateInvoicingDetailChiles < ActiveRecord::Migration[5.1]
  def change
    create_table :chile_invoicing_details do |t|
      t.string :tax_id
      t.string :giro
      t.string :ciudad
      t.string :comuna
      t.references :issue, foreign_key: true
      t.references :person, foreign_key: true

      t.timestamps
    end
  end
end
