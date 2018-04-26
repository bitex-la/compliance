class AffinitySeed < ApplicationRecord
  include Garden::Seed
  include Garden::Kindify
  belongs_to :related_person, class_name: 'Person'
  validates  :affinity_kind, inclusion: { in: AffinityKind.all.map(&:code) }

  kind_mask_for :affinity_kind, "AffinityKind"
end
