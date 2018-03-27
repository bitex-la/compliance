class AffinitySeed < ApplicationRecord
  include Garden::Seed
  belongs_to :related_person, class_name: 'Person'
  validates :kind, relationship_kind: true
end
