class ArgentinaInvoicingDetailSerializer 
  include FastJsonapiCandy::Fruit
  attributes :vat_status_id, :tax_id, :tax_id_type, :receipt_type, 
    :country, :address
  build_timestamps
  derive_seed_serializer!
end
