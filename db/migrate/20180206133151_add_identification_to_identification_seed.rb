class AddIdentificationToIdentificationSeed < ActiveRecord::Migration[5.1]
  def change
    add_reference :identification_seeds, :identification, foreign_key: { to_table: :identifications }
  end
end
