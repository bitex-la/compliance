class RegularitySerializer
  include FastJsonapiCandy::Serializer
  set_type 'regularities'

  attributes :code, :funding_amount, :funding_count
end