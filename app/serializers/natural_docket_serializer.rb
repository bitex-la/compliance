class NaturalDocketSerializer
  include FastJsonapiCandy::PersonThing
  derive_seed_serializer!
  attributes :first_name, :last_name, :birth_date, :nationality, :gender,
    :marital_status
end
