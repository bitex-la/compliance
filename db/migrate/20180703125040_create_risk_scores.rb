class CreateRiskScores < ActiveRecord::Migration[5.1]
  def change
    create_table :risk_scores do |t|
      t.string :score
      t.string :provider
      t.text :extra_info
      t.string :external_link
      t.references :issue, foreign_key: true
      t.references :person, foreign_key: true

      t.timestamps
    end
  end
end
