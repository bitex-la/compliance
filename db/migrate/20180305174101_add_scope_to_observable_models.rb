class AddScopeToObservableModels < ActiveRecord::Migration[5.1]
  def change
    add_column :observations, :scope, :integer
    add_column :observation_reasons, :scope, :integer
  end
end
