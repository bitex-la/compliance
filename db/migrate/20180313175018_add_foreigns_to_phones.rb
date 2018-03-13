class AddForeignsToPhones < ActiveRecord::Migration[5.1]
  def change
    add_reference :phone_seeds, :replaces, foreign_key: { to_table: :phones }
    add_reference :phone_seeds, :fruit, foreign_key: { to_table: :phones }
    add_reference :phones, :replaced_by, foreign_key: { to_table: :phones }
    add_reference :phones, :issue, foreign_key: { to_table: :issues }
  end
end
