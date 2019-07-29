class AddsSeedToObservations < ActiveRecord::Migration[5.2]
  def change
    add_reference :observations, :observable, polymorphic: true, index: true
  end
end
