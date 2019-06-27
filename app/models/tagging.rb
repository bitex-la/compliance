module Tagging
  extend ActiveSupport::Concern

  included do
    belongs_to taggable_type
    belongs_to :tag
    
    validates taggable_type, presence: true
    validates :tag,
      uniqueness: { 
        scope: taggable_type,
        message: "can't contain duplicates in the same #{taggable_type}" 
      }
    
    validate :tag_type_must_be_correct_type

    def tag_type_must_be_correct_type
      return if tag&.tag_type == self.class.taggable_type.to_s
      errors.add(:tag, "can't be blank and must be #{self.class.taggable_type} tag")
    end
  end
end