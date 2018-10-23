class ModifyColumnsForRisk < ActiveRecord::Migration[5.1]
  def change
    change_column :risk_score_seeds, :external_link, :longtext
    change_column :risk_scores, :external_link, :longtext
  end
end
