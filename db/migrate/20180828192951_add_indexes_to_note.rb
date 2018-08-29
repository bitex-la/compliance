class AddIndexesToNote < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!
  def change
    %i(notes note_seeds).each do |entity|
      add_index entity, :title, :algorithm => :copy
    end
  end
end
