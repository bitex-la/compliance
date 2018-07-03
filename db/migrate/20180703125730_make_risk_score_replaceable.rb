class MakeRiskScoreReplaceable < ActiveRecord::Migration[5.1]
  def change
    add_column :risk_score_seeds, :replaces_id, :integer
    add_reference :risk_score_seeds, :fruit, foreign_key: { to_table: :risk_scores }
    add_reference :risk_scores, :replaced_by, foreign_key: {to_table: :risk_scores}
  end
end
