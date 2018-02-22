class NaturalDocketSeedsSerializer
  include FastJsonapi::ObjectSerializer
  set_type :natural_docket_seeds
  attributes :first_name, :last_name, :birth_date, :nationality, :gender, :marital_status
  belongs_to :issue
  belongs_to :natural_docket
end