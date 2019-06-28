class AddExpireAtToSeeds < ActiveRecord::Migration[5.2]
  def change
    %i(affinity_seeds allowance_seeds argentina_invoicing_detail_seeds chile_invoicing_detail_seeds 
    domicile_seeds email_seeds identification_seeds legal_entity_docket_seeds natural_docket_seeds
    note_seeds phone_seeds risk_score_seeds
    ).each do |column|
      add_column column, :expires_at, :date
    end
  end
end
