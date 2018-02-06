class AddReplacedByToIdentification < ActiveRecord::Migration[5.1]
  def change
    add_reference :identifications, :replaced_by, foreign_key: { to_table: :identifications }
  end
end
