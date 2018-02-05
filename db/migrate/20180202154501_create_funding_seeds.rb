class CreateFundingSeeds < ActiveRecord::Migration[5.1]
  def change
    create_table :funding_seeds do |t|
      t.references :issue, foreign_key: true
      t.decimal :amount, precision: 10
      t.string :kind

      t.timestamps
    end
  end
end
