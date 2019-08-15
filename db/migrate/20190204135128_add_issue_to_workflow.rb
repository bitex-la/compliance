class AddIssueToWorkflow < ActiveRecord::Migration[5.1]
  def change
    add_reference :workflows, :issue, foreign_key: true
  end
end
