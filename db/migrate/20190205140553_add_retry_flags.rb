class AddRetryFlags < ActiveRecord::Migration[5.1]
  def change
    add_column :tasks, :max_retries, :integer, default: 0
    add_column :tasks, :current_retries, :integer, default: 0
  end
end
