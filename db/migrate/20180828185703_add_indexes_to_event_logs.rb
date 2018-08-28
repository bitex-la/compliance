class AddIndexesToEventLogs < ActiveRecord::Migration[5.1]
  def change
    add_index :event_logs, [:entity_id, :entity_type], :algorithm => :copy
    add_index :event_logs, :entity_id, :algorithm => :copy
    add_index :event_logs, :entity_type, :algorithm => :copy
    add_index :event_logs, :verb_id, :algorithm => :copy
  end
end
