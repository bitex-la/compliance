class AffinitySeed < AffinityBase
  include Garden::Seed
  validate :linked_once_in_issue

  before_save :add_update_affinity_tag
  after_destroy :remove_affinity_tag

  def not_linked_to_itself
    return if issue.nil?
    return unless related_person.try(:id) == issue.person.id

    errors.add(:base, 'cannot_link_to_itself')
  end

  def linked_once_by_affinity
    return if issue.nil?
    return unless affinity_exist?(issue.person, related_person, affinity_kind, archived_at) ||
                  affinity_exist?(related_person, issue.person, affinity_kind, archived_at)

    errors.add(:base, 'affinity_already_exists')
  end

  def linked_once_in_issue
    return if issue.nil?
    return unless affinity_defined?(issue, related_person, affinity_kind)

    errors.add(:base, 'affinity_already_defined')
  end

  def affinity_defined?(issue, related_one, kind)
    active_issues = issue.person.issues
      .where(aasm_state: %w(draft new observed answered))
      .pluck(:id)

    AffinitySeed.where(issue_id: active_issues, related_person: related_one, 
      affinity_kind_id: kind.try(:id))
      .where.not(id: id).count > 0
  end

  def get_label(current_issue)
    return affinity_kind.code if person == current_issue.person
    return affinity_kind.inverse if related_person == current_issue.person
  end

  def related_one(current_issue)
    return related_person if person == current_person
    return current_issue.person if related_person == current_issue.person
  end

  private

  def add_update_affinity_tag
    affinity_kind_changed = affinity_kind_id_changed? && affinity_kind_id_was
    related_person_changed = related_person_id_changed? && related_person_id_was

    if affinity_kind_changed
      kind = AffinityKind.find(affinity_kind_id_was)
      tag_name = kind.affinity_to_tag
      inverse_tag_name = kind.inverse_of_tag
      if related_person_changed
        Person
          .find(related_person_id_was)
          .remove_tag(tag_name)
      else
        related_person.remove_tag(tag_name)
      end
      person.remove_tag(inverse_tag_name)
    end

    if related_person_changed
      unless affinity_kind_changed
        Person
          .find(related_person_id_was)
          .remove_tag(affinity_kind.affinity_to_tag)
      end
    end

    return unless affinity_kind.affinity_to_tag

    person.add_tag(affinity_kind.inverse_of_tag)
    related_person.add_tag(affinity_kind.affinity_to_tag)
  end

  def remove_affinity_tag
    person.remove_tag(affinity_kind.inverse_of_tag)
    related_person.remove_tag(affinity_kind.affinity_to_tag)
  end
end
