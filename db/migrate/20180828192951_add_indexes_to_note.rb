class AddIndexesToNote < ActiveRecord::Migration[5.1]
  def change
    %i(notes note_seeds).each do |entity|
      add_index entity, :title, :algorithm => :copy
    end
  end
end
