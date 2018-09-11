class LegalEntityDocketSeed < ApplicationRecord
  include Garden::Seed
  include SeedApiExpirable
  validates :country, country: true
end
