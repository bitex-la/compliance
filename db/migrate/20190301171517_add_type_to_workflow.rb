class AddTypeToWorkflow < ActiveRecord::Migration[5.1]
  def change
    remove_column :workflows, :workflow_kind_id , :integer
    add_column :workflows, :workflow_type, :string
  end
end
