class PersonTagging < ApplicationRecord
  def self.taggable_type
    :person
  end

  def self.tag_type
    :person
  end

  include Tagging

  validate :person_tag_must_be_managed_by_admin

  def person_tag_must_be_managed_by_admin
    return unless person

    return if person.tags.empty?

    unless (tags = AdminUser.current_admin_user&.active_tags)
      return
    end

    return if tags.empty?

    return if person.tags.any? { |t| AdminUser.current_admin_user.can_manage_tag?(t) }

    errors.add(:person, 'Person tags not allowed')
  end
end
