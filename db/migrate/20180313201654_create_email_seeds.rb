class CreateEmailSeeds < ActiveRecord::Migration[5.1]
  def change
    create_table :email_seeds do |t|
      t.string :address
      t.string :kind
      t.references :issue, foreign_key: true

      t.timestamps
    end
  end
end
