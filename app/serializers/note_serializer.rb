class NoteSerializer
  include FastJsonapiCandy::Fruit
  attributes :title, :body, :private
  build_timestamps
  derive_seed_serializer!
  derive_public_seed_serializer!(:private)
end
