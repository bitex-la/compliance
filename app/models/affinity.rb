class Affinity < AffinityBase
  include Garden::Fruit

  def not_linked_to_itself
    errors.add(:base, 'cannot_link_to_itself') if related_person.try(:id) == person.id  
  end

  def linked_once_by_affinity
    if affinity_exist?(person, related_person, affinity_kind) || 
      affinity_exist?(related_person, person, affinity_kind)
      errors.add(:base, 'affinity_already_exists')
    end
  end
end
