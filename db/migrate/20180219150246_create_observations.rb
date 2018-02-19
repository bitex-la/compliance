class CreateObservations < ActiveRecord::Migration[5.1]
  def change
    create_table :observations do |t|
      t.references :issue, foreign_key: true

      t.timestamps
    end
  end
end
