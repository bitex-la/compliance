class IdentificationSeedSerializer
  include FastJsonapi::ObjectSerializer
  attributes :kind, :number, :issuer
  belongs_to :issue
  belongs_to :identification
end