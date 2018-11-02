class AffinitySeed < AffinityBase
  include Garden::Seed

  def linked_once_by_affinity
    return if issue.nil?
    if affinity_exist?(issue.person, related_person, affinity_kind) || 
      affinity_exist?(related_person, issue.person, affinity_kind)
      errors.add(:base, 'affinity_already_exists')
    end
  end
end
