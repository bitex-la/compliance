class AddPersonExternalId < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :external_id, :integer
  end
end
