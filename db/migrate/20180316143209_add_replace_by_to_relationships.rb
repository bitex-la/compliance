class AddReplaceByToRelationships < ActiveRecord::Migration[5.1]
  def change
    add_reference :relationships, :replaced_by, foreign_key: {to_table: :relationships}
  end
end
