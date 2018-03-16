class RelationshipSeed < ApplicationRecord
  include Garden::Seed
  belongs_to :related_person, class_name: 'Person'
end
