class NaturalDocketSerializer
  include FastJsonapiCandy::Fruit
  attributes :first_name, :last_name, :birth_date, :nationality, :gender,
    :marital_status, :job_title, :job_description,
    :politically_exposed, :politically_exposed_reason
  build_timestamps
  derive_seed_serializer!
end
