class RenameAllKindColumns < ActiveRecord::Migration[5.1]
  def change
    change_column :natural_docket_seeds, :marital_status_id, :bigint
    change_column :natural_dockets, :marital_status_id, :bigint

    rename_column :natural_docket_seeds, :gender, :gender_id
    rename_column :natural_dockets, :gender, :gender_id 
    
    change_column :natural_docket_seeds, :gender_id, :bigint
    change_column :natural_dockets, :gender_id, :bigint
  end
end
