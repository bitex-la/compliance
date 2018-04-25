class ChileInvoicingDetailSerializer 
  include FastJsonapiCandy::Fruit
  attributes :vat_status, :tax_id, :giro, :ciudad, :comuna
  build_timestamps
  derive_seed_serializer!
end
