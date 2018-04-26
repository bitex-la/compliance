class Affinity < ApplicationRecord 
  include Garden::Fruit
  include Garden::Kindify
  belongs_to :related_person, class_name: 'Person'
  validates  :affinity_kind, inclusion: { in: AffinityKind.all.map(&:code) }
  
  kind_mask_for :affinity_kind, "AffinityKind"
end
