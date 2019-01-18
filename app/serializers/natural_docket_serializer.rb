class NaturalDocketSerializer
  include FastJsonapiCandy::Fruit
  attributes :first_name, :last_name, :nationality, :gender_code,
    :marital_status_code, :job_title, :job_description,
    :politically_exposed, :politically_exposed_reason,
    :birth_date

  build_timestamps
  derive_seed_serializer!
  derive_public_seed_serializer!
end
