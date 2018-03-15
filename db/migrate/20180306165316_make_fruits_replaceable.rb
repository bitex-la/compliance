class MakeFruitsReplaceable < ActiveRecord::Migration[5.1]
  def change
    reversible do |dir|
      dir.up do
        drop_table :funding_seeds if table_exists? :funding_seeds
      end
    end

    %w(allowance domicile identification relationship).each do |table|
      add_column "#{table}_seeds", :replaces_id, :integer
    end

    %w(legal_entity_docket natural_docket
    allowance domicile identification).each do |table|
      rename_column "#{table}_seeds", "#{table}_id", :fruit_id
    end
    add_column :relationship_seeds, :fruit_id, :integer
  end
end
