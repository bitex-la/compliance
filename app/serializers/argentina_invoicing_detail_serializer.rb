class ArgentinaInvoicingDetailSerializer 
  include FastJsonapiCandy::Fruit
  attributes :vat_status_id, :tax_id
  derive_seed_serializer!
end
