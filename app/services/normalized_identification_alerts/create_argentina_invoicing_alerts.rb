module NormalizedIdentificationAlerts
  class CreateArgentinaInvoicingAlerts < NormalizedIdentificationAlertsBase
  
    def search_duplicates
      return if seed.normalize_tax_id.nil?

      tax_id_kind, identifications_kind = seed.tax_id_kind_id == TaxIdKind.dni.id ? [ TaxIdKind.dni.id, IdentificationKind.national_id.id ] : [[ TaxIdKind.cuil.id, TaxIdKind.cuit.id ], IdentificationKind.tax_id.id]
      invoicings = search_query(seed_class, { tax_id_kind_id: tax_id_kind, tax_id_normalized: seed.tax_id_normalized })
      identifications = search_query(IdentificationSeed, {identification_kind_id: identifications_kind, issuer: 'AR', number_normalized: seed.tax_id_normalized })
      
      (invoicings + identifications)
    end
  end
end
