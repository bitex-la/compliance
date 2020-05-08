module Tagging
  extend ActiveSupport::Concern

  included do
    belongs_to taggable_type
    belongs_to :tag

    validates taggable_type, presence: true
    validates :tag,
      presence: true,
      uniqueness: {
        scope: taggable_type,
        message: "can't contain duplicates in the same #{taggable_type}"
      }

    validate :tag_type_must_be_correct_type

    def tag_type_must_be_correct_type
      return if tag&.tag_type == self.class.tag_type.to_s

      errors.add(:tag, "can't be blank and must be #{self.class.tag_type} tag")
    end

    validate :tag_cannot_be_changed_once_set

    def tag_cannot_be_changed_once_set
      return unless tag_id_was.presence && tag_id_was != tag_id

      errors.add(:base, 'cant_change_tag')
    end

    validate :taggable_type_cannot_be_changed_once_set

    def taggable_type_cannot_be_changed_once_set
      id = send("#{self.class.taggable_type}_id")
      id_was = send("#{self.class.taggable_type}_id_was")

      return unless id_was.presence && id_was != id

      errors.add(:base, 'cant_change_taggable_type')
    end
  end
end
