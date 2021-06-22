class AddMultipleIndexOnLegalEntityDockets < ActiveRecord::Migration[5.2]
  def change
    add_index(
      :legal_entity_dockets,
      %i[person_id archived_at replaced_by_id],
      name: 'index_legal_entity_dockets_for_person_type_search'
    )
  end
end
