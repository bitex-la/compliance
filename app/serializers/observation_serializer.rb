class ObservationSerializer
  include FastJsonapiCandy::Serializer
  set_type 'observations'
  build_timestamps
  build_belongs_to :issue
  build_belongs_to :observation_reason
  has_one :observable, polymorphic: true
  attributes *%i(note reply state scope)
  %i(subject body).each do |f|
    %i(en es pt).each do |l|
      name = "#{f}_#{l}"
      attribute name do |object|
        object.observation_reason.try(name)
      end
    end
  end
end
