class CreateChileInvoicingDetailSeeds < ActiveRecord::Migration[5.1]
  def change
    create_table :chile_invoicing_detail_seeds do |t|
      t.string :tax_id
      t.string :giro
      t.string :ciudad
      t.string :comuna
      t.references :issue, foreign_key: true

      t.timestamps
    end
  end
end
