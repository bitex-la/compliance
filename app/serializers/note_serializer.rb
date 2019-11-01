class NoteSerializer
  include FastJsonapiCandy::Fruit
  attributes :title, :body, :public
  build_timestamps
  derive_seed_serializer!
end
