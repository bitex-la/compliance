class Affinity < AffinityBase
  include Garden::Fruit

  def linked_once_by_affinity
    if affinity_exist?(person, related_person, affinity_kind) || 
      affinity_exist?(related_person, person, affinity_kind)
      errors.add(:base, 'affinity_already_exists')
    end
  end
end
