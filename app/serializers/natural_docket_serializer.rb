class NaturalDocketSerializer
  include FastJsonapi::ObjectSerializer
  attributes :first_name, :last_name, :birth_date, :nationality, :gender, :marital_status, :replaced_by_id
  belongs_to :issue
  belongs_to :person
  has_many :natural_docket_seeds
end