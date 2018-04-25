class AffinitySerializer
  include FastJsonapiCandy::Fruit
  set_type 'affinities'
  attributes :affinity_kind
  build_timestamps
  belongs_to :related_person, record_type: :people
  derive_seed_serializer!
end
