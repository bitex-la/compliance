class NaturalDocketSerializer
  include FastJsonapiCandy::PersonThing
  attributes :first_name, :last_name, :birth_date, :nationality, :gender,
    :marital_status
  derive_seed_serializer!
end
