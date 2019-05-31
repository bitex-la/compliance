class AddExpireAtToSeeds < ActiveRecord::Migration[5.2]
  def change
    add_column :affinity_seeds, :expires_at, :date
    add_column :allowance_seeds, :expires_at, :date
    add_column :argentina_invoicing_detail_seeds, :expires_at, :date
    add_column :chile_invoicing_detail_seeds, :expires_at, :date
    add_column :domicile_seeds, :expires_at, :date
    add_column :email_seeds, :expires_at, :date
    add_column :identification_seeds, :expires_at, :date
    add_column :legal_entity_docket_seeds, :expires_at, :date
    add_column :natural_docket_seeds, :expires_at, :date
    add_column :note_seeds, :expires_at, :date
    add_column :phone_seeds, :expires_at, :date
    add_column :risk_score_seeds, :expires_at, :date
  end
end
