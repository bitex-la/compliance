class Affinity < AffinityBase
  include Garden::Fruit

  def not_linked_to_itself
    return unless related_person.try(:id) == person.id

    errors.add(:base, 'cannot_link_to_itself')
  end

  def linked_once_by_affinity
    return unless affinity_exist?(person, related_person, affinity_kind, archived_at) ||
      affinity_exist?(related_person, person, affinity_kind, archived_at)

    errors.add(:base, 'affinity_already_exists')
  end

  def get_label(current_person)
    return affinity_kind.code  if person == current_person
    return affinity_kind.inverse  if related_person == current_person
  end

  def related_one(current_person)
    return related_person if person == current_person
    return person if related_person == current_person
  end

  def unscoped_get_label(current_person)
    return affinity_kind.code  if person_id == current_person.id
    return affinity_kind.inverse  if related_person_id == current_person.id
  end

  def unscoped_related_one(current_person)
    return Person.unscoped.find(related_person_id) if person_id == current_person.id
    return Person.unscoped.find(person_id) if related_person_id == current_person.id
  end
end
