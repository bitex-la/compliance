class RemoveEventLogIndex < ActiveRecord::Migration[5.2]
  def up
    remove_index :event_logs, [:entity_type, :verb_id] if index_exists?(:event_logs, [:entity_type, :verb_id])
  end

  def down

  end
end
