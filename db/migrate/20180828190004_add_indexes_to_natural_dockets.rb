class AddIndexesToNaturalDockets < ActiveRecord::Migration[5.1]
  def change
    %i(natural_dockets natural_docket_seeds).each do |entity|
      add_index entity, [:first_name, :last_name], :algorithm => :copy
      add_index entity, :first_name, :algorithm => :copy
      add_index entity, :last_name, :algorithm => :copy
      add_index entity, :birth_date, :algorithm => :copy
      add_index entity, :nationality, :algorithm => :copy
      add_index entity, :gender_id, :algorithm => :copy
      add_index entity, :marital_status_id, :algorithm => :copy
    end
  end
end
