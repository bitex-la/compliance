class AddIndexesToArgentinaInvoicing < ActiveRecord::Migration[5.1]
  def change
    %i(argentina_invoicing_details argentina_invoicing_detail_seeds).each do |entity|
      add_index entity, :vat_status_id, :algorithm => :copy
      add_index entity, :tax_id, :algorithm => :copy
      add_index entity, :tax_id_kind_id, :algorithm => :copy
      add_index entity, :receipt_kind_id, :algorithm => :copy
      add_index entity, :full_name, :algorithm => :copy
      add_index entity, :address, :algorithm => :copy
      add_index entity, :country, :algorithm => :copy
    end
  end
end
