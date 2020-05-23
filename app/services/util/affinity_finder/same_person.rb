module AffinityFinder
  class SamePerson
    # Returns Array[Int] (person_ids of orphans if any)
    def self.call(person_id)
      person = Person.find(person_id)

      # find uniq ids of persons matchin name or identification
      matched_ids = with_matched_id_numbers(person).to_set
      matched_ids.merge(with_matched_names(person))

      affinity_persons_ids = matched_affinity_persons(matched_ids)

      # TODO: get all existing same_person childrens of person

      if affinity_persons_ids.empty?
        return # TODO: RETURN ALL CURRENT SAME_PERSON AFF CHILDRENS OF person (all orphans)
      end

      affinity_persons_ids.each do |affinity_person_id|
        # TODO: if is an existing children remove from orphans array
        create_same_person_issue(person, Person.find(affinity_person_id))
      end
    end

    # affinity related_to other persons (i.e. only fathers)
    # params matched_ids Array[Int] -> person_ids
    # Returns Array[Int] person_ids with no same_person
    def self.matched_affinity_persons(matched_ids)
      return nil if matched_ids.empty?

      affinity_persons = []
      persons_ids_linked_by_affinity = []
      matched_ids.each do |match_id|
        continue if persons_ids_linked_by_affinity.include?(match_id)

        affinity_person = same_name_affinity_person_father(match_id)

        persons_ids_linked_by_affinity.push(
          same_name_affinity_person_childrens(affinity_person.id).pluck(:person_id)
        )

        affinity_persons << affinity_person.id
      end

      affinity_persons.uniq
    end

    # returns [?Person]
    def self.same_name_affinity_person_childrens(person_id)
      Affinity.where(
        related_person_id: person_id,
        affinity_kind_id: AffinityKind.find_by_code('same_person').id
      )
    end

    # returns Person
    def self.same_name_affinity_person_father(person_id)
      affinity_person = Person.find(person_id)

      # check if there is a same_person affinity
      # already linked to this affinity_person
      # i.e. an affinity father
      found_affinity = affinity_person.affinities.find_by(
        affinity_kind_id: AffinityKind.find_by_code('same_person').id
      )

      found_affinity&.related_person || affinity_person
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
      # pending_issue_ids = affinity_person.issues.where(

      # ).pluck(:id)

      # maybe using affinity_exist? issue's method
      # if affinity_exist?(issue.person, related_person, affinity_kind) ||
      #   affinity_exist?(related_person, issue.person, affinity_kind)

      # existing_affinities = AffinitySeed.where(
      #             related_person: affinity_person,
      #             affinity_kind_id: AffinityKind.find_by_code(:same_person).id
      # )

      # TODO: check if there is an existing pending issue with this affinity_person

      issue = person.issues.build(state: 'new', reason: IssueReason.new_risk_information)
      issue.affinity_seeds.build(
        related_person: affinity_person,
        affinity_kind: AffinityKind.find_by_code(:same_person)
      )

      issue.save!
    end
  end
end