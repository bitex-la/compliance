class Person < ApplicationRecord
  has_many :issues
  has_many :domiciles
  has_many :identifications
  has_many :natural_dockets
  has_many :legal_entity_dockets
  has_many :quotas, class_name: "Quotum"
  has_many :comments, as: :commentable
end
