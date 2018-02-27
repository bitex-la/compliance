class DomicileSerializer
  include FastJsonapiCandy::PersonThing
  attributes :country, :state, :city, :street_address, :street_number,
    :postal_code, :floor, :apartment
  derive_seed_serializer!
end
