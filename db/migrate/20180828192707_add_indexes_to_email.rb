class AddIndexesToEmail < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!
  def change
    %i(emails email_seeds).each do |entity|
      add_index entity, :address, :algorithm => :copy
      add_index entity, :email_kind_id, :algorithm => :copy
    end
  end
end
