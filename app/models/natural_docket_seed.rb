class NaturalDocketSeed < ApplicationRecord
  include Garden::Seed
  validates :nationality, country: true
  validates :gender, gender: true
  validates :marital_status, marital_status: true  
end
