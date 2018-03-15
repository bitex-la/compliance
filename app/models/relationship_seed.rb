class RelationshipSeed < ApplicationRecord
  include Garden::Seed
  belongs_to :related_person
end
