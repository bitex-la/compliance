class PersonTagging < ApplicationRecord
  belongs_to :person
  belongs_to :tag
  
  validates :person, presence: true
  validates :tag,
    uniqueness: { 
      scope: :person,
      message: "cant't contains duplicates in the same person" 
    }
  
  validate :tag_type_must_be_person

  def tag_type_must_be_person
    return unless tag.nil? || tag.tag_type != "person"
    errors.add(:tag, "can't be blank and must be a person tag")
  end
end