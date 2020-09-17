class AffinitySeed < AffinityBase
  include Garden::Seed
  validate :linked_once_in_issue

  before_save :add_affinity_tag
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

  def add_affinity_tag
    return unless affinity_kind.affinity_to_tag

    if related_person_id_changed? && related_person_id_was
      Person
        .find(related_person_id_was)
        .person_taggings
        .joins(:tag)
        .where('tags.name': affinity_kind.inverse_of_tag)
        .delete_all
    end

    tag = Tag.find_or_create_by(tag_type: :person, name: affinity_kind.affinity_to_tag)
    PersonTagging.find_or_create_by(tag: tag, person: person)

    related_tag = Tag.find_or_create_by(tag_type: :person, name: affinity_kind.inverse_of_tag)
    PersonTagging.find_or_create_by(tag: related_tag, person: related_person)
  end

  def remove_affinity_tag
    person
      .person_taggings
      .joins(:tag)
      .where('tags.name': affinity_kind.affinity_to_tag)
      .delete_all

    related_person
      .person_taggings
      .joins(:tag)
      .where('tags.name': affinity_kind.inverse_of_tag)
      .delete_all
  end

end
