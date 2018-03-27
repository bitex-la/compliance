class AffinitySerializer
  include FastJsonapiCandy::Fruit
  set_type 'affinities'
  attributes :kind  
  derive_seed_serializer!
end
