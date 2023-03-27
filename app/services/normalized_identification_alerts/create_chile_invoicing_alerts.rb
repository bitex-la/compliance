
module NormalizedIdentificationAlerts
  class CreateChileInvoicingAlerts < NormalizedIdentificationAlertsBase

    def search_duplicates
      return if seed.normalize_tax_id.nil?

      invoicings = search_query(seed_class, { tax_id_normalized: seed.tax_id_normalized })
      identifications = search_query(IdentificationSeed, { identification_kind_id: IdentificationKind.tax_id.id, issuer: 'CL', number_normalized: seed.tax_id_normalized })
      
      (invoicings + identifications)
    end    
  end
end
