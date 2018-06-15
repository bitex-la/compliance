class CreateEventLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :event_logs do |t|
      t.integer :entity_id
      t.string :entity_type
      t.text :raw_data, limit: 4294967295
      t.references :admin_user, foreign_key: true

      t.timestamps
    end
  end
end
