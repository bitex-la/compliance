class Relationship < ApplicationRecord 
  include Garden::Fruit
  belongs_to :related_person
end
