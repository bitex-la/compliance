class Util::AffinityFulfilment
  def self.call(affinity_seeds)
    # Determine if this affinity_seed should be process as is
    # or must be changed. Also check if other affinities must be archived
    #
    # I only evaluate the first one because the same_person affinity process
    # only creates one affinity_seed per issue
    affinity_seed = affinity_seeds.first

    unless affinity_seed.archived_at
      # keep current affinities of the
      # affinity_seed person if there still valid
      person = affinity_seed.person
      related_person = affinity_seed.related_person

      current_affinities = person.affinities.by_kind(:same_person)
      orphans = []

      # revalidate relationship between father and current childrens
      current_affinities.each do |current_affinity|
        unless same_person_match(person, current_affinity.related_person)
          # there is an edge case that a father is not related to a children
          # directly but through an existing sibling (se result in edge case J.)
          unless same_person_match_any_related_person(current_affinities, current_affinity, person)
            archive_affinity!(current_affinity)
            orphans.push(current_affinity.related_person)
          end
        end
      end

      # if the result is more than one orphan,
      # build same_person affinity between them
      if orphans.count > 1
        sorted_orphans = orphans.sort_by {|p| p.id}
        father = sorted_orphans.shift
        sorted_orphans.each do |orphan|
          build_same_person_affinity!(father, orphan)
        end
      end

      # if related_person has another same_person father,
      # and still matches, move as sibling
      # if not, archive the affinity
      related_person_related_affinities = related_person.related_affinities.by_kind(:same_person)
      related_person_related_affinities.each do |old_father_affinity|
        archive_affinity!(old_father_affinity)
        if (same_person_match(related_person, old_father_affinity.person))
          old_father = old_father_affinity.person
          build_same_person_affinity!(person, old_father)
        end
      end

      # if children has childrens (of previous relationship),
      # and still matches, move as sibling
      # if not, archive the affinity
      related_person_affinities = related_person.affinities.by_kind(:same_person)
      related_person_affinities.each do |related_person_affinity|
        archive_affinity!(related_person_affinity)
        if (same_person_match_any_related_person(related_person_affinities, related_person_affinity, person))
          build_same_person_affinity!(person, related_person_affinity.related_person)
        end
      end
    end

    return
  end

  def self.after_process(affinity_seeds)
    # This method evaluates the existing same_person relationship
    # of the new children

    # I only evaluate the first one because the same_person affinity process
    # only creates one affinity_seed per issue
    affinity_seed = affinity_seeds.first
    person = affinity_seed.person
    related_person = affinity_seed.related_person

    # if person has a same_person father, and still matches, move his children/s
    # if not, archive the affinity
    person.related_affinities.by_kind(:same_person).each do |father_affinity|
      if (same_person_match(father_affinity.person, person))
        person.affinities.by_kind(:same_person).each do |children_affinity|
          archive_affinity!(children_affinity)
          build_same_person_affinity!(father_affinity.person, children_affinity.related_person)
        end
      else
        archive_affinity!(father_affinity)
      end
    end
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

  def self.same_person_match(person, related_person)
    id1 = person.identifications.current&.first&.number
    id2 = related_person.identifications.current&.first&.number

    name1 = person.natural_docket&.name_body
    name2 = related_person.natural_docket&.name_body

    match_by_identification(id1, id2) || match_by_name(name1, name2)
  end

  def self.same_person_match_any_related_person(affinities, current_affinity, father)
    return true if same_person_match(current_affinity.person, current_affinity.related_person)
    affinities.each do |affinity|
      next if affinity == current_affinity
      if (
        same_person_match(father, affinity.related_person) &&
        same_person_match(affinity.related_person, current_affinity.related_person)
      )
        return true
      end
    end
    return false
  end

  def self.match_by_identification(id1, id2)
    if (id1 && id2)
      return (
        !!id1.downcase.match(id2.downcase) ||
        !!id2.downcase.match(id1.downcase)
      )
    end
    return false
  end

  def self.match_by_name(name1, name2)
    if (name1 && name2)
      return (
        !!Regexp.union(name1.downcase.split(/\W+/)).match(name2.downcase) ||
        !!Regexp.union(name2.downcase.split(/\W+/)).match(name1.downcase)
      )
    end
    return false
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