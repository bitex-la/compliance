class AddReplacedByToLegalEntityDocket < ActiveRecord::Migration[5.1]
  def change
    add_reference :legal_entity_dockets, :replaced_by, foreign_key: { to_table: :legal_entity_dockets }
  end
end