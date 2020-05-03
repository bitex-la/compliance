module AffinityFinder
  class SamePerson
    # Crear servicio orquestador que llama a este servicio

    # Returns Array[Int] (person_ids of orphans if any)
    def self.call(person_id)
      person = Person.find(person_id)

      matched_ids = with_matched_id_numbers(person).to_set
      matched_ids.merge(with_matched_names(person))

      return nil if matched_ids.empty?

      persons_ids_linked_by_affinity = []
      matched_ids.each do |match_id|
        continue if persons_ids_linked_by_affinity.include?(match_id)

        affinity_person = person.find(match_id)

        # check if there is a same_person affinity
        # already linked to this affinity_person
        if found_affinity = Affinity.find_by(
          related_person_id: affinity_person.id,
          kind: 'same_person'
        )
          affinity_person = found_affinity.person
        end

        # TODO: chequear validez de affinities preexistentes si person
        # tiene affinities same_person activos y marcarlos de alguna manera
        # para invalidarlos si person es hijo. En caso de que sea Padre
        # se debe marcar a los related_persons de los affinities a expirar
        # para correr en cada related_person el affinity creator de same_person
        create_same_person_issue(person, affinity_person)

        # Crear issues por cada

        persons_ids_linked_by_affinity << Affinity.where(
          person_id: affinity_person_id,
          kind: 'same_person'
        ).pluck(:related_person_id)

        # PRIMER CASO
          # verifico si hay affinity a otra person,
          # si lo tiene creo issue con el person padre.
          # creo issue con primera person_id encontrada
          # baneo los person_id que esta primera person tenga como
          # affinities same_person black_list
        # CASOS SIGUIENTES
          # fijarme si esta en black_list continue
          # verifico si hay affinity a otra person,
          # si lo tiene creo issue con el person padre.
          # Antes de crear issue verificar issue pendiente de aprobar con la misma affinity entre las mismas persons
          # Issue con AffinitySeed same_person relacionando a la persona nueva con el
          # paso issue a complete
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
      # By using CONCAT we are not taking advantage of any index
      # (YET -->)In the newest versions of MySQL 8.0 and MariaDB 10,
      # you can index "virtual" columns.

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
                          #{conditions.join(' AND ')}",
                          person_id: person.id
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

    def create_same_person_issue(related_person, person)
      # create issue only if there is not a pending
      # for the same persons with same affinity seed
      # TODO...

      issue = person.issues.build

      # TODO create same_person_affinity_seed in issue

    end
  end
end