class PersonTagging < ApplicationRecord
  def self.taggable_type
    :person
  end

  def self.tag_type
    :person
  end

  include Tagging
  include PersonScopeable

  validate :person_tag_must_be_managed_by_admin

  def person_tag_must_be_managed_by_admin
    return unless person&.tags.presence
    return if AdminUser.current_admin_user.can_manage_tag?(tag)

    errors.add(:person, 'admin_cant_manage_tag')
  end
end
