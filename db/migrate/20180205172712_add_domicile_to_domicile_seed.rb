class AddDomicileToDomicileSeed < ActiveRecord::Migration[5.1]
  def change
    add_reference :domicile_seeds, :domicile, foreign_key: { to_table: :domiciles }
  end
end
