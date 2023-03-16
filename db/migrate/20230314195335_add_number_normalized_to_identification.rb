class AddNumberNormalizedToIdentification < ActiveRecord::Migration[5.2]
  def change
    add_column :identifications, :number_normalized, :string
    add_index :identifications, :number_normalized, unique: false
  end
end
