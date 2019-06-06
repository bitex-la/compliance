class AddReasonToIssues < ActiveRecord::Migration[5.2]
  def change
    add_column :issues, :reason_id, :integer, null:true

    #todo update reason in older issues and set not nullable
  end
end
