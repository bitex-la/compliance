class NoteSerializer
  def self.attrs_exceptions
    [:private]
  end

  include FastJsonapiCandy::Fruit
  attributes :title, :body, :private
  build_timestamps
  derive_seed_serializer!
  derive_public_seed_serializer! attrs_exceptions
end
