class AddVerbToEventLog < ActiveRecord::Migration[5.1]
  def change
    add_column :event_logs, :verb, :integer
  end
end
