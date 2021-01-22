class NaturalDocketSerializer
  include FastJsonapiCandy::Fruit
  attributes :first_name, :last_name, :nationality, :gender_code,
    :marital_status_code, :job_title, :job_description,
    :politically_exposed, :politically_exposed_reason,
    :birth_date, :expected_investment

  build_timestamps
  derive_seed_serializer!
end
