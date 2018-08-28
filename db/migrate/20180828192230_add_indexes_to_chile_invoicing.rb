class AddIndexesToChileInvoicing < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!
  def change
    %i(chile_invoicing_details chile_invoicing_detail_seeds).each do |entity|
      add_index entity, :vat_status_id, :algorithm => :copy
      add_index entity, :tax_id, :algorithm => :copy
      add_index entity, :giro, :algorithm => :copy
      add_index entity, :comuna, :algorithm => :copy
    end
  end
end
