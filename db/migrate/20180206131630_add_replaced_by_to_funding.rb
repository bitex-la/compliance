class AddReplacedByToFunding < ActiveRecord::Migration[5.1]
  def change
    add_reference :fundings, :replaced_by, foreign_key: { to_table: :fundings }
  end
end
