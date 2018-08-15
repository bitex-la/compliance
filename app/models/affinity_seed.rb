class AffinitySeed < ApplicationRecord
  include Garden::Seed
  include StaticModels::BelongsTo

  belongs_to :related_person, class_name: 'Person'
  validates  :affinity_kind, inclusion: { in: AffinityKind.all }

  belongs_to :affinity_kind
end
