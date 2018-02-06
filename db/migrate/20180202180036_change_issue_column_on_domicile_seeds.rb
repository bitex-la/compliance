class ChangeIssueColumnOnDomicileSeeds < ActiveRecord::Migration[5.1]
  def change
    rename_column :domicile_seeds, :issues_id, :issue_id
  end
end
