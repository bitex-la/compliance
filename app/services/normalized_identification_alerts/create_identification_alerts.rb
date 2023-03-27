
module NormalizedIdentificationAlerts
  class CreateIdentificationAlerts < NormalizedIdentificationAlertsBase

    def search_duplicates
      return if seed.number_normalized.nil?
      return unless [ 'AR', 'CL' ].include?(seed.issuer)
      return unless [ IdentificationKind.national_id.id, IdentificationKind.tax_id.id ].include?(seed.identification_kind_id)

      identifications = search_query(seed_class, { identification_kind_id: IdentificationKind.public_send(seed.identification_kind.code).id,
                                                   issuer: seed.issuer, number_normalized: seed.number_normalized })
      if seed.issuer == 'AR'
        tax_id_kind_id = seed.identification_kind_id == IdentificationKind.national_id.id ? TaxIdKind.dni.id : [ TaxIdKind.cuil.id, TaxIdKind.cuit.id ]
        invoicings = search_query(ArgentinaInvoicingDetailSeed, { tax_id_kind_id: tax_id_kind_id, tax_id_normalized: seed.number_normalized })
      else
        invoicings = search_query(ChileInvoicingDetailSeed, { tax_id_normalized: seed.number_normalized })
      end
      
      (invoicings + identifications)
    end
  end
end
