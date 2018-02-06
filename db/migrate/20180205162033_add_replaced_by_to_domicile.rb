class AddReplacedByToDomicile < ActiveRecord::Migration[5.1]
  def change
    add_reference :domiciles, :replaced_by, foreign_key: { to_table: :domiciles }
  end
end
