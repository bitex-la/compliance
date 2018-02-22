class IdentificationsSeedSerializer
  include FastJsonapi::ObjectSerializer
  set_type :identification_seeds
  attributes :kind, :number, :issuer
  belongs_to :issue
  belongs_to :identification
end