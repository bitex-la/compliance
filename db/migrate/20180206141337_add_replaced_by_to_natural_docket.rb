class AddReplacedByToNaturalDocket < ActiveRecord::Migration[5.1]
  def change
    add_reference :natural_dockets, :replaced_by, foreign_key: { to_table: :natural_dockets }
  end
end
