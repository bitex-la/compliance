class AddMissingIndices < ActiveRecord::Migration[5.1]
  def change
    %i(affinity_seeds allowance_seeds domicile_seeds
       identification_seeds risk_score_seeds
    ).each do |table|
      add_index table, :replaces_id
    end

    add_index :affinity_seeds, :fruit_id
  end
end
