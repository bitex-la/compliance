class AddArchiveAtIndexes < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :affinities, :archived_at, :algorithm => :copy
    add_index :affinity_seeds, :archived_at, :algorithm => :copy
    add_index :allowances, :archived_at, :algorithm => :copy
    add_index :allowance_seeds, :archived_at, :algorithm => :copy
    add_index :argentina_invoicing_detail_seeds, :archived_at, :algorithm => :copy
    add_index :argentina_invoicing_details, :archived_at, :algorithm => :copy
    add_index :chile_invoicing_detail_seeds, :archived_at, :algorithm => :copy
    add_index :chile_invoicing_details, :archived_at, :algorithm => :copy
    add_index :domicile_seeds, :archived_at, :algorithm => :copy
    add_index :domiciles, :archived_at, :algorithm => :copy
    add_index :email_seeds, :archived_at, :algorithm => :copy
    add_index :emails, :archived_at, :algorithm => :copy
    add_index :identification_seeds, :archived_at, :algorithm => :copy
    add_index :identifications, :archived_at, :algorithm => :copy
    add_index :legal_entity_docket_seeds, :archived_at, :algorithm => :copy
    add_index :legal_entity_dockets, :archived_at, :algorithm => :copy
    add_index :natural_docket_seeds, :archived_at, :algorithm => :copy
    add_index :natural_dockets, :archived_at, :algorithm => :copy
    add_index :note_seeds, :archived_at, :algorithm => :copy
    add_index :notes, :archived_at, :algorithm => :copy
    add_index :phone_seeds, :archived_at, :algorithm => :copy
    add_index :phones, :archived_at, :algorithm => :copy
    add_index :risk_score_seeds, :archived_at, :algorithm => :copy
    add_index :risk_scores, :archived_at, :algorithm => :copy
  end
end
