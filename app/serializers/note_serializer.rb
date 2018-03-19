class NoteSerializer
  include FastJsonapiCandy::Fruit
  attributes :title, :body  
  derive_seed_serializer!
end
