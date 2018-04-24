class RenameKindColumns < ActiveRecord::Migration[5.1]
  def change
    rename_column :natural_docket_seeds, :marital_status, :marital_status_id
    rename_column :natural_dockets, :marital_status, :marital_status_id 
  end
end
