class ChileInvoicingDetailSerializer 
  include FastJsonapiCandy::Fruit
  attributes :vat_status_code, :tax_id, :giro, :ciudad, :comuna
  build_timestamps
  derive_seed_serializer!
  derive_public_seed_serializer!
end
