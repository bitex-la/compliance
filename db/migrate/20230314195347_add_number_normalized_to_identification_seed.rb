class AddNumberNormalizedToIdentificationSeed < ActiveRecord::Migration[5.2]
  def change
    add_column :identification_seeds, :number_normalized, :string
    add_index :identification_seeds, :number_normalized, unique: false
  end
end
