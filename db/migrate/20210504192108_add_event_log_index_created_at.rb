class AddEventLogIndexCreatedAt < ActiveRecord::Migration[5.2]
  def change
    add_index :event_logs, :created_at, :algorithm => :copy
  end
end
