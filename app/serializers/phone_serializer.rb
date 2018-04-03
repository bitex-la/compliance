class PhoneSerializer
  include FastJsonapiCandy::Fruit
  attributes :number, :kind, :country, :has_whatsapp, :has_telegram, :note 
  derive_seed_serializer!
end
