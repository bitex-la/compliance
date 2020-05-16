module AffinityFinder
  class SamePerson
    # Returns Array[Int] (person_ids of orphans if any)
    def self.call(person_id)
      person = Person.find(person_id)

      # find uniq ids of persons matchin name or identification
      matched_ids = with_matched_id_numbers(person).to_set
      matched_ids.merge(with_matched_names(person))

      affinity_persons = matched_affinity_person(matched_ids)

      return if affinity_persons.empty?

      affinity_persons.each do |affinity_person|
        create_same_person_issue(person, affinity_person)
      end
    end

    def self.matched_affinity_persons(matched_ids)
      return nil if matched_ids.empty?

      persons_ids_linked_by_affinity = []
      matched_ids.each do |match_id|
        continue if persons_ids_linked_by_affinity.include?(match_id)

        affinity_person = Person.find(match_id)

        # check if there is a same_person affinity
        # already linked to this affinity_person
        # i.e. an affinity father
        found_affinity = affinity_person.affinites.find_by(
          affinity_kind_id: AffinityKind.find_by_code('same_person').id
        )

        affinity_person = found_affinity&.related_person || affinity_person

        persons_ids_linked_by_affinity << Affinity.where(
          related_person_id: affinity_person.id,
          affinity_kind_id: AffinityKind.find_by_code('same_person').id
        ).pluck(:person_id)
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

          match_names.pluck(:person_id)
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

    def self.create_same_person_issue(person, affinity_person)
      # create issue only if there is not a pending
      # for the same persons with same affinity seed

      # Question: I wonder if it's a better way
      # to find pendings issues other than this? 👇
      pending_issue_ids = affinity_person.issues.admin_pending.pluck(:id)
      return if AffinitySeed.where(
                  issue_id: pending_issue_ids,
                  related_person: person,
                  affinity_kind: AffinityKind.find_by_code(:same_person)
      ).count > 0

      issue = affinity_person.issues.build(state: 'new', reason: IssueReason.new_risk_information)
      issue.affinity_seeds.build(
        related_person: person,
        affinity_kind: AffinityKind.find_by_code(:same_person)
      )
    end
  end
end