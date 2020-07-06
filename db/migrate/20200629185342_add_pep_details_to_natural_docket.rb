class AddPepDetailsToNaturalDocket < ActiveRecord::Migration[5.2]
  def change
    add_column :natural_dockets,      :country_pep,         :string
    add_column :natural_dockets,      :kind_pep_arg,        :string, null: true
    add_column :natural_dockets,      :full_name_pep_chile, :string, null: true
    add_column :natural_dockets,      :id_pep_chile,        :string, null: true
    add_column :natural_dockets,      :remote_ip,           :string, null: true
    add_column :natural_docket_seeds, :country_pep,         :string
    add_column :natural_docket_seeds, :kind_pep_arg,        :string, null: true
    add_column :natural_docket_seeds, :full_name_pep_chile, :string, null: true
    add_column :natural_docket_seeds, :id_pep_chile,        :string, null: true
    add_column :natural_docket_seeds, :remote_ip,           :string, null: true
  end
end