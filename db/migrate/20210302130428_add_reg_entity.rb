class AddRegEntity < ActiveRecord::Migration[5.2]
  def change
    add_column :legal_entity_dockets, :regulated_entity, :boolean, null: false, default: false
    add_column :legal_entity_docket_seeds, :regulated_entity, :boolean, null: false, default: false

    add_column :legal_entity_dockets, :operations_with_third_party_funds, :boolean, null: false, default: false
    add_column :legal_entity_docket_seeds, :operations_with_third_party_funds, :boolean, null: false, default: false
  end
end
