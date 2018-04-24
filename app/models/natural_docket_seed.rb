class NaturalDocketSeed < ApplicationRecord
  include Garden::Seed
  include Garden::Kindify
  validates :nationality, country: true
  #validates :gender, gender: true
  #validates :marital_status, marital_status: true 

  kind_mask_for :marital_status
  kind_mask_for :gender
end
