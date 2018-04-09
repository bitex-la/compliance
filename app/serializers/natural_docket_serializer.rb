class NaturalDocketSerializer
  include FastJsonapiCandy::Fruit
  attributes :first_name, :last_name, :nationality, :gender,
    :marital_status, :job_title, :job_description,
    :politically_exposed, :politically_exposed_reason
  attribute :birth_date do |obj|
    obj.birth_date.to_time.to_i
  end
  build_timestamps
  derive_seed_serializer!
end
