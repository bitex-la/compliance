class CreateRiskScoreSeeds < ActiveRecord::Migration[5.0]
  def change
    create_table :risk_score_seeds do |t|
      t.string :score
      t.string :provider
      t.text :extra_info
      t.string :external_link
      t.references :issue, foreign_key: true
  
      t.timestamps
    end
  end
end
