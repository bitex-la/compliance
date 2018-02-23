class DomicileSerializer
  include FastJsonapiCandy::PersonThing
  attributes :country, :state, :city, :street_address, :street_number,
    :postal_code, :floor, :apartment
  build_has_many :attachments
end
