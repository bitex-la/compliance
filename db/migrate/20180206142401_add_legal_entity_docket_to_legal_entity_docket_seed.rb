class AddLegalEntityDocketToLegalEntityDocketSeed < ActiveRecord::Migration[5.1]
  def change
    add_reference :legal_entity_docket_seeds, :legal_entity_docket, foreign_key: { to_table: :legal_entity_dockets }
  end
end
