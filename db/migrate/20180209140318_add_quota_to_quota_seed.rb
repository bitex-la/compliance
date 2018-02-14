class AddQuotaToQuotaSeed < ActiveRecord::Migration[5.1]
  def change
    add_reference :quota_seeds, :quota, foreign_key: { to_table: :quota }
  end
end
