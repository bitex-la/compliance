module AffinityFinder
  class SamePerson
    def self.call(person)

      matched_ids = with_matched_id_numbers(person)

      return nil if matched_ids.empty?

      persons_ids_linked_by_affinity = []
      matched_ids.uniq.sort.each do |person_id|
        continue if persons_ids_linked_by_affinity.include?(person_id)

        affinity_person = person.find(person_id)

        # check if there is a same_person affinity
        # already linked to this affinity_person
        # TODO: refactor this to a helper in affinity (?)
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
        "person_id <> :person_id AND
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
          return [] if person.natural_dockets.count == 0

          NaturalDocket.current.where(
            "person_id <> :person_id AND
            (LOWER(concat(first_name,' ',last_name)) LIKE LOWER(:name)
            OR LOWER(:name) LIKE LOWER(concat('%', first_name, ' ', last_name, '%')))",
            name: person.natural_dockets.last.name_body
          ).pluck(:person_id).uniq
        when :legal_entity
          return [] if person.legal_entity_dockets.count == 0

          LegalEntityDocket.current.where(
            "person_id <> :person_id AND
            (LOWER(comercial_name) LIKE LOWER(:name)
            OR LOWER(:name) LIKE LOWER(comercial_name)
            OR LOWER(legal_name) LIKE LOWER(:name)
            OR LOWER(:name) LIKE LOWER(legal_name))",
            name: person.legal_entity_dockets.last.name_body
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