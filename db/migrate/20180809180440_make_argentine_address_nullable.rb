class MakeArgentineAddressNullable < ActiveRecord::Migration[5.1]
  def change
    change_column :argentina_invoicing_detail_seeds, :address, :string, null: true
    change_column :argentina_invoicing_details, :address, :string, null: true
  end
end
