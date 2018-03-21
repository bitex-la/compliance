class IdentificationSeed < ApplicationRecord
  include Garden::Seed
  validates :issuer, country: true
  validates :kind, identification_kind: true 
end
