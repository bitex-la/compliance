class AddEventLogIndex < ActiveRecord::Migration[5.2]
  def change
    add_index :event_logs, [:entity_type, :verb_id], :algorithm => :copy
  end
end
