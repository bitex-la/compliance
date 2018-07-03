class CopyAttachmentsForRiskScores < ActiveRecord::Migration[5.1]
  def change
    add_column :risk_score_seeds, :copy_attachments, :boolean
  end
end
