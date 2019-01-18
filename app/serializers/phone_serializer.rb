class PhoneSerializer
  include FastJsonapiCandy::Fruit
  attributes :number, :phone_kind_code, :country, :has_whatsapp, 
    :has_telegram, :note
  build_timestamps
  derive_seed_serializer!
  derive_public_seed_serializer!
end
