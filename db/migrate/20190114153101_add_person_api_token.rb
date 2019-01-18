class AddPersonApiToken < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :api_token, :string
  end
end
