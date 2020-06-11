module AffinityFinder
  class SamePerson
    # Returns Array[Int] (person_ids of orphans if any) DEPRECATED
    # Returns VOID (all arrengements on children are going to happen
    # in issue approval process)
    def self.call(person_id)
      person = Person.find(person_id)

      # find uniq ids of persons matchin name or identification
      matched_ids = with_matched_id_numbers(person).to_set
      matched_ids.merge(with_matched_names(person))

      children_ids =  same_person_affinity_childrens(person_id).pluck(:related_person_id)

      issues_created = false
      matched_ids.each do |match_person_id|
        # if is an existing children remove from orphans array and move on
        next if children_ids.delete(match_person_id)

        # check if match_person_id has a same_person father
        match_person = same_person_affinity_father(match_person_id)

        (father_id, children_id) = [person.id, match_person.id].sort

        create_same_person_issue!(father_id, children_id)
        issues_created = true
      end

      create_archived_issues_on_orphans(person, children_ids) unless issues_created
    end

    # affinity related_to other persons (i.e. only fathers)
    # params matched_ids Array[Int] -> person_ids
    # Returns Array[Int] person_ids with no same_person
    def self.related_persons(matched_ids)
      return nil if matched_ids.empty?

      related_persons = []
      persons_ids_linked_by_affinity = []

      matched_ids.each do |match_id|
        continue if persons_ids_linked_by_affinity.include?(match_id)

        related_person = same_person_affinity_father(match_id)

        persons_ids_linked_by_affinity.push(
          same_person_affinity_childrens(related_person.id).pluck(:person_id)
        )

        related_persons << related_person.id
      end

      related_persons.uniq
    end

    # returns [?Person]
    def self.same_person_affinity_childrens(person_id)
      Affinity.where(
        person_id: person_id,
        affinity_kind_id: AffinityKind.find_by_code('same_person').id
      )
    end

    # returns Person
    def self.same_person_affinity_father(person_id)
      if (affinity = Affinity.find_by(
                                related_person_id: person_id,
                                affinity_kind_id: AffinityKind.find_by_code('same_person').id
                              ))
        return affinity.person
      else
        return Person.find(person_id)
      end
    end

    # Returns Array[Int] (matched Person Ids)
    def self.with_matched_id_numbers(person)
      # This method matches person identification numbers
      # (exact match or one containg the other) on Identification collection.
      # The query use REGEXP operator in MySQL in order to get the result
      # in a single call (https://dev.mysql.com/doc/refman/5.7/en/regexp.html#operator_regexp)
      return [] if person.identifications.pluck(:number).empty?

      Identification.current.where(
        "identifications.person_id <> :person_id AND
        (LOWER(number) REGEXP LOWER(:numbers)
        OR LOWER(:numbers) REGEXP LOWER(number))",
        person_id: person.id,
        numbers: person.identifications.pluck(:number).join('|')
      ).pluck(:person_id).uniq
    end

    # Returns Array[Int] (matched Person Ids)
    def self.with_matched_names(person)
      case person.person_type
        when :natural_person
          return [] if person.natural_dockets.current.count == 0

          full_name = person.natural_dockets.current.last.name_body

          conditions = []
          full_name.split(/\W+/).each do |word|
            conditions << "
                (first_name REGEXP '[[:<:]]#{word}[[:>:]]' OR
                last_name REGEXP '[[:<:]]#{word}[[:>:]]')
            "
          end

          match_names = NaturalDocket.current.where(
                          "natural_dockets.person_id <> :person_id AND
                          ((first_name IN (:words) AND last_name IN (:words)) OR
                          (#{conditions.join(' AND ')}))",
                          person_id: person.id,
                          words: full_name.split(/\W+/),
                        )

          match_names.pluck(:person_id).uniq
        when :legal_entity
          return [] if person.legal_entity_dockets.current.count == 0

          docket = person.legal_entity_dockets.current.last

          legal_match_conditions = []
          legal_match_conditions.push(
            'LOWER(commercial_name) = :commercial_name'
          ) if docket.commercial_name && !docket.commercial_name.empty?
          legal_match_conditions.push(
            'LOWER(legal_name) = :legal_name'
          ) if docket.legal_name && !docket.legal_name.empty?

          legal_matches = LegalEntityDocket.current.where.not(person: person)

          LegalEntityDocket.current.where(
            "legal_entity_dockets.person_id <> :person_id AND
            (#{legal_match_conditions.join(' OR ')})",
            person_id: person.id,
            commercial_name: docket.commercial_name&.downcase,
            legal_name: docket.legal_name&.downcase
          ).pluck(:person_id).uniq
        else
          return []
      end
    end

    def self.create_same_person_issue!(person_id, related_person_id)
      # create issue only if there is not a pending
      # for the same persons with same affinity seed
      person = Person.find(person_id)
      related_person = Person.find(related_person_id)
      affinity_kind = AffinityKind.find_by_code(:same_person)

      issue = person.issues.build(state: 'new', reason: IssueReason.new_risk_information)
      affinity = issue.affinity_seeds.build(
        related_person: related_person,
        affinity_kind: affinity_kind
      )

      # save unless affinity is already defined
      issue.save! unless affinity.affinity_defined?(issue, related_person, affinity_kind)
    end

    def self.create_archived_issues_on_orphans(person, orphan_ids)
      affinity_kind = AffinityKind.find_by_code(:same_person)
      orphan_ids.each do |orphan_id|
        current_affinity = person.affinities.find_by!(
          related_person_id: orphan_id,
          affinity_kind_id: affinity_kind.id
        )
        issue = person.issues.build(state: 'new', reason: IssueReason.new_risk_information)
        affinity = issue.affinity_seeds.build(
          related_person_id: orphan_id,
          affinity_kind: affinity_kind,
          replaces: current_affinity,
          archived_at: Date.current
        )

        issue.save!
      end
    end
  end
end