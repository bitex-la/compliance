class ArgentinaInvoicingDetailSerializer
  include FastJsonapiCandy::Fruit
  attributes :vat_status_code, :tax_id, :tax_id_kind_code, :receipt_kind_code,
    :country, :address, :full_name
  build_timestamps
  derive_seed_serializer!
  derive_public_seed_serializer!
end
