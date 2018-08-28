class RenameVerbColumn < ActiveRecord::Migration[5.1]
  def change
    rename_column :event_logs, :verb, :verb_id
  end
end
