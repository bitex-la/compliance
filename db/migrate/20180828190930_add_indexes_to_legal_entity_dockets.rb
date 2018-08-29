class AddIndexesToLegalEntityDockets < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!
  def change
    %i(legal_entity_dockets legal_entity_docket_seeds).each do |entity|
      add_index entity, :country, :algorithm => :copy
      add_index entity, :commercial_name, :algorithm => :copy
      add_index entity, :legal_name, :algorithm => :copy
    end
  end
end
