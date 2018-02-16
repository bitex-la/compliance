class NaturalDocketSeedSerializer
  include FastJsonapi::ObjectSerializer
  attributes :first_name, :last_name, :birth_date, :nationality, :gender, :marital_status
  belongs_to :issue
  belongs_to :natural_docket
end