class AddFieldsToObservations < ActiveRecord::Migration[5.1]
  def change
    create_table :observation_reasons do |t|
      t.string :subject
      t.text   :body  

      t.timestamps
    end

    add_column :observations, :note, :text
    add_column :observations, :reply, :text
    add_reference :observations, :observation_reason
  end
end
