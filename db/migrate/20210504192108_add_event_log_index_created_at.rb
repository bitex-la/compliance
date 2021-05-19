class AddEventLogIndexCreatedAt < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  
  def change
    add_index :event_logs, :created_at, :algorithm => :copy
  end
end
