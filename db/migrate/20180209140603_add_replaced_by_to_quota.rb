class AddReplacedByToQuota < ActiveRecord::Migration[5.1]
  def change
    add_reference :quota, :replaced_by, foreign_key: { to_table: :quota }
  end
end
