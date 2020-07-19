class Affinity < AffinityBase
  include Garden::Fruit

  scope :by_kind, -> (code){ where(affinity_kind_id: AffinityKind.find_by_code(code.to_sym).id) }

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
end
