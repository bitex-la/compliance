class NoteSerializer
  include FastJsonapiCandy::Fruit
  attributes :title, :body
  build_timestamps
  derive_seed_serializer!
end
