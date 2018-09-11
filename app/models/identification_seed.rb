class IdentificationSeed < ApplicationRecord
  include Garden::Seed
  include SeedApiExpirable
  include StaticModels::BelongsTo

  validates :issuer, country: true
  validates :identification_kind, inclusion: { in: IdentificationKind.all }

  belongs_to :identification_kind, class_name: "IdentificationKind"
end
