class CreateIssues < ActiveRecord::Migration[5.1]
  def change
    create_table :issues do |t|
      t.references :person, foreign_key: true

      t.timestamps
    end
  end
end
