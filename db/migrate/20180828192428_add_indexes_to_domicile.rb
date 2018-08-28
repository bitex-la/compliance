class AddIndexesToDomicile < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!
  def change
    %i(domiciles domicile_seeds).each do |entity|
      add_index entity, :country, :algorithm => :copy
      add_index entity, :state, :algorithm => :copy
      add_index entity, :city, :algorithm => :copy
      add_index entity, :street_address, :algorithm => :copy
      add_index entity, :street_number, :algorithm => :copy
      add_index entity, [:street_address, :street_number], :algorithm => :copy
      add_index entity, :postal_code, :algorithm => :copy
    end
  end
end
