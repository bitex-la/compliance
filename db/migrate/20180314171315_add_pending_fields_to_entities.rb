class AddPendingFieldsToEntities < ActiveRecord::Migration[5.1]
  def change
    add_column :natural_dockets, :job_title, :string
    add_column :natural_dockets, :job_description, :string
    add_column :natural_dockets, :politically_exposed, :boolean
    add_column :natural_dockets, :politically_exposed_reason, :text
  
    add_column :natural_docket_seeds, :job_title, :string
    add_column :natural_docket_seeds, :job_description, :string
    add_column :natural_docket_seeds, :politically_exposed, :boolean
    add_column :natural_docket_seeds, :politically_exposed_reason, :text

    add_column :identifications, :public_registry_authority, :string
    add_column :identifications, :public_registry_book, :string
    add_column :identifications, :public_registry_extra_data, :string

    add_column :identification_seeds, :public_registry_authority, :string
    add_column :identification_seeds, :public_registry_book, :string
    add_column :identification_seeds, :public_registry_extra_data, :string
  end
end
