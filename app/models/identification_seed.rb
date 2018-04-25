class IdentificationSeed < ApplicationRecord
  include Garden::Seed
  include Garden::Kindify
  validates :issuer, country: true
  #validates :kind, identification_kind: true 

  kind_mask_for :identification_kind, "IdentificationKind"
end
