class ChileInvoicingDetailSerializer 
  include FastJsonapiCandy::Fruit
  attributes :tax_id, :giro, :ciudad, :comuna
  derive_seed_serializer!
end
