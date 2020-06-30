module AffinityFinder
  class SamePerson
    # Returns Array[Int] (person_ids of orphans if any) DEPRECATED
    # Returns VOID (all arrengements on children are going to happen
    # in issue approval process)
    def self.call(person)
      # find uniq ids of persons matchin name or identification
      matched_ids = with_matched_id_numbers(person).to_set
      matched_ids.merge(with_matched_names(person))

      children_ids =  person.affinities.where(
                        affinity_kind_id: AffinityKind.same_person.id
                      ).pluck(:related_person_id)

      issues_created = false
      matched_ids.each do |matched_person_id|
        # if is an existing children remove from orphans array and move on
        next if children_ids.delete(matched_person_id)

        # check if match_person_id has a same_person father
        # and is included in matched array
        affinity_father = same_person_affinity_father(matched_person_id)

        if affinity_father && matched_ids.include?(affinity_father.id)
          matched_person = affinity_father
        else
          matched_person = Person.find(matched_person_id)
        end

        (father, children) = [person, matched_person].sort_by {|p| p.id}

        create_same_person_issue(father, children)
        issues_created = true
      end

      create_archived_issues_on_orphans(person, children_ids) unless issues_created
    end

    # returns Person
    def self.same_person_affinity_father(person_id)
      affinity = Affinity.current.find_by(
        related_person_id: person_id,
        affinity_kind_id: AffinityKind.same_person.id
      )

      affinity&.person
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
          return [] if person.natural_dockets.count == 0

          full_name = person.natural_docket.name_body

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
          return [] if person.legal_entity_dockets.count == 0

          docket = person.legal_entity_docket

          legal_match_conditions = []
          legal_match_conditions.push(
            'LOWER(commercial_name) = :commercial_name'
          ) if !docket.commercial_name.blank?
          legal_match_conditions.push(
            'LOWER(legal_name) = :legal_name'
          ) if !docket.legal_name.blank?

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

    def self.create_same_person_issue(person, related_person)
      # create issue only if there is not a pending
      # for the same persons with same affinity seed
      issue = person.issues.build(state: 'new', reason: IssueReason.new_risk_information)
      issue.affinity_seeds.build(
        related_person: related_person,
        affinity_kind: AffinityKind.same_person
      )

      issue.save
    end

    def self.create_archived_issues_on_orphans(person, orphan_ids)
      affinity_kind = AffinityKind.same_person
      orphan_ids.each do |orphan_id|
        current_affinity = person.affinities.find_by!(
          related_person_id: orphan_id,
          affinity_kind_id: affinity_kind.id
        )

        issue = person.issues.build(state: 'new', reason: IssueReason.new_risk_information)
        affinity = issue.affinity_seeds.build(
          related_person: Person.find(orphan_id),
          affinity_kind: affinity_kind,
          replaces: current_affinity,
          archived_at: Date.current
        )

        issue.save!
      end
    end
  end
end
