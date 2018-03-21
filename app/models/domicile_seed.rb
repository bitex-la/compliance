class DomicileSeed < ApplicationRecord
  include Garden::Seed
  validates :country, country: true
end
