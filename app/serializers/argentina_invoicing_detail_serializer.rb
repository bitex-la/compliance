class ArgentinaInvoicingDetailSerializer
  include FastJsonapiCandy::Fruit
  attributes :vat_status, :tax_id, :tax_id_kind, :receipt_kind,
    :country, :address, :name
  build_timestamps
  derive_seed_serializer!
end
