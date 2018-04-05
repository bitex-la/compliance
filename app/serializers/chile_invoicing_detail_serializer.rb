class ChileInvoicingDetailSerializer 
  include FastJsonapiCandy::Fruit
  attributes :vat_status_id, :tax_id, :giro, :ciudad, :comuna
  derive_seed_serializer!
end
