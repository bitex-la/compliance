class ModifyColumnTypesForTexts < ActiveRecord::Migration[5.1]
  def change
    change_column :natural_docket_seeds, :job_description, :text
    change_column :natural_dockets, :job_description, :text
  end
end
