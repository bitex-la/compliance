class AddIndexesToObservation < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!
  def change
    add_index :observation_reasons, :subject_en, :algorithm => :copy
    add_index :observation_reasons, :subject_es, :algorithm => :copy
    add_index :observation_reasons, :subject_pt, :algorithm => :copy
    add_index :observation_reasons, :scope, :algorithm => :copy
    add_index :observations, :scope, :algorithm => :copy
    add_index :observations, :aasm_state, :algorithm => :copy
  end
end
