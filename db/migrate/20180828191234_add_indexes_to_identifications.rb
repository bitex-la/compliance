class AddIndexesToIdentifications < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!
  def change
    %i(identifications identification_seeds).each do |entity|
      add_index entity, :identification_kind_id, :algorithm => :copy
      add_index entity, :number, :algorithm => :copy
      add_index entity, :issuer, :algorithm => :copy
    end
  end
end
