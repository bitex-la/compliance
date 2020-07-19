class Util::AffinityFulfilment
  def self.call(affinity_seeds)
    # Determine if this affinity_seed should be process as is
    # or must be changed. Also check if other affinities must be archived
    affinity_seed = affinity_seeds.first

    unless affinity_seed.archived_at
      # archive previous same_person affinity and related_affinities
      # of related person
      related_person = affinity_seed.related_person
      related_person_affinities = related_person.affinities.by_kind(:same_person)
      related_person_affinities.each do |related_person_affinity|
        archive_affinity!(related_person_affinity)
        build_same_person_affinity!(affinity_seed.person, related_person_affinity.related_person)
      end
      related_person_related_affinities = related_person.related_affinities.by_kind(:same_person)
      related_person_related_affinities.each do |related_person_related_affinity|
        next if related_person_related_affinity == affinity_seed.fruit
        archive_affinity!(related_person_related_affinity)
      end
    end

    return
  end

  private

  def self.archive_affinity!(related_person_affinity)
    issue = related_person_affinity.person.issues.build(state: 'new', reason: IssueReason.new_risk_information)
    affinity = issue.affinity_seeds.build(
      related_person: related_person_affinity.related_person,
      affinity_kind: AffinityKind.find_by_code(:same_person),
      replaces: related_person_affinity,
      archived_at: Date.current
    )

    issue.save!
    issue.approve!
  end

  def self.build_same_person_affinity!(person, related_person)
    issue = person.issues.build(state: 'new', reason: IssueReason.new_risk_information)
    issue.affinity_seeds.build(
      related_person: related_person,
      affinity_kind: AffinityKind.same_person
    )

    issue.save!
    issue.approve!
  end
end