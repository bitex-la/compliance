class AddIssueTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :issue_tokens do |t|
      t.string :token, null: false
      t.references :issue, null: false
      t.datetime :valid_until, null: false
    end
  end
end
