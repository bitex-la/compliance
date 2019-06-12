class PersonTagging < ApplicationRecord
  belongs_to :person
  belongs_to :tag
  validates :person, presence: true
  validates :tag, presence: true,
    uniqueness: { 
      scope: :person,
      message: "cant't contains duplicates in the same person" 
    } 
end