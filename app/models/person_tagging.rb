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
    return unless person

    return if person.tags.empty?

    unless (admin_user = AdminUser.current_admin_user)
      return
    end

    return if person.tags.any? { |t| admin_user.can_manage_tag?(t) }

    errors.add(:person, 'Person tags not allowed')
  end

  before_destroy :destroyable?

  def destroyable?
    return if person

    raise 'Destroy not allowed'
  end
end
