class AllowanceSerializer
  def self.attrs_exceptions
    [:amount, :weight]
  end

  include FastJsonapiCandy::Fruit
  attributes :weight, :amount, :kind_code
  build_timestamps
  derive_seed_serializer!
  derive_public_seed_serializer! attrs_exceptions
end
