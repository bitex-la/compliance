class LegalEntityDocketSeed < ApplicationRecord
  include Garden::Seed
  validates :country, country: true
end
