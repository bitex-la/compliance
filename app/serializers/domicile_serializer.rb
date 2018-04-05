class DomicileSerializer
  include FastJsonapiCandy::Fruit
  attributes :country, :state, :city, :street_address, :street_number,
    :postal_code, :floor, :apartment
  build_timestamps
  derive_seed_serializer!
end
