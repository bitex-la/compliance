class AddTypeToWorkflow < ActiveRecord::Migration[5.1]
  def change
    remove_column :workflows, :workflow_kind_id
    add_column :workflows, :workflow_type, :string
  end
end
