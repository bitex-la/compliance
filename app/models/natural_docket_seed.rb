class NaturalDocketSeed < ApplicationRecord
  include Garden::Seed
  include Garden::Kindify
  validates :nationality, country: true
  validates :gender, inclusion: { in: GenderKind.all.map(&:code) }
  validates :marital_status, inclusion: { in: MaritalStatusKind.all.map(&:code) }  

  kind_mask_for :marital_status
  kind_mask_for :gender
end
