class IdentificationSeed < ApplicationRecord
  include Garden::Seed
  include Garden::Kindify
  validates :issuer, country: true
  validates :identification_kind, inclusion: { in: IdentificationKind.all.map(&:code) }

  kind_mask_for :identification_kind, "IdentificationKind"
end
