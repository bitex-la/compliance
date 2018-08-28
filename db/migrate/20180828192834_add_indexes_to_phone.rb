class AddIndexesToPhone < ActiveRecord::Migration[5.1]
  def change
    %i(phones phone_seeds).each do |entity|
      add_index entity, :number, :algorithm => :copy
      add_index entity, :phone_kind_id, :algorithm => :copy
      add_index entity, :country, :algorithm => :copy
    end
  end
end
