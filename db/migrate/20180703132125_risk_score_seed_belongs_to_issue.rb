class RiskScoreSeedBelongsToIssue < ActiveRecord::Migration[5.1]
  def change
    add_reference :risk_score_seeds, :issue, foreign_key: { to_table: :issues }
  end
end
