class AddNaturalDocketToNaturalDocketSeed < ActiveRecord::Migration[5.1]
  def change
    add_reference :natural_docket_seeds, :natural_docket, foreign_key: { to_table: :natural_dockets }
  end
end
