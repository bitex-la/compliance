require_relative 'affinity_serializer'

class AffinitySeedSerializer
  belongs_to :related_person,
    record_type: :people,
    serializer: 'PersonSerializer'
end