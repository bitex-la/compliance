class AddForeignsToEmails < ActiveRecord::Migration[5.1]
  def change
    add_reference :email_seeds, :replaces, foreign_key: { to_table: :emails }
    add_reference :email_seeds, :fruit, foreign_key: { to_table: :emails }
    add_reference :emails, :replaced_by, foreign_key: { to_table: :emails }
  end
end
