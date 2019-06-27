class AffinitySeedSerializer
  include FastJsonapiCandy::Seed
  belongs_to :related_person,
    record_type: :people,
    serializer: 'PersonSerializer'
end