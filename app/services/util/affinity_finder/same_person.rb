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

    def self.with_matched_id_numbers(person)
      # This method matches person identification numbers
      # (exact match or one containg the other) on Identification collection.
      # The query use REGEXP operator in MySQL in order to get the result
      # in a single call (https://dev.mysql.com/doc/refman/5.7/en/regexp.html#operator_regexp)
      Identification.where(
        "person_id <> :person_id AND
        replaced_by_id is NULL AND
        (number REGEXP :numbers
        OR :numbers REGEXP number)",
        person_id: person.id,
        numbers: person.identifications.pluck(:number).join('|')
      ).pluck(:person_id)
    end

    def self.with_matched_names(person)
#       if (a.identificacion_number parecido(igualdad o uno contiene al otro) b.identification_number)
#         creo issue
#       elsif ((a.last_name + a.name).split.to_set.subset?((b.last_name + b.name).split.to_set))
#       || ((b.last_name + b.name).split.to_set.subset?((a.last_name + a.name).split.to_set))
#       creo issue
#       end
    end

    def create_same_person_issue(related_person, person)
      # create issue only if there is not a pending
      # for the same persons with same affinity seed
      # TODO...

      issue = person.issues.build

      # TODO create same_person_affinity_seed in issue

    end

      # Ejemplo de cambio de datos de padre e hijo en affinities
      # PERSONA A NOMBRE IGUAL DNI DISTINTO
      # PERSONA B NOMBRE IGUAL DNI DISTINTO (Persona A es padre)

      # PERSONA F NOMBRE DIST DNI DIST
      # PERSONA G NOMBRE DIST DNI IGUAL A (Persona A es padre)

      # PERSONA H NOMBRE IGUAL PERSONA F  DNI IGUAL A B (Persona A y F padre)

      # PERSONA H cambia NOMBRE o # PERSONA F cambia NOMBRE


      # Creates an issue with AffinitySeed affinity_kind_code: :same_person
      # expiration??

      # Ejemplo de cambio de person que es padre e hijo a la vez
      # PERSONA A
      # PERSONA B NOMBRE = A DNI DISTINTO (Persona A es padre)
      # PERSONA C NOMBRE DIST DNI = B (Persona B es padre)
      # PERSONA D NOMBRE DIST DNI = B (Persona B es padre)
      # EDITO PERSONA B
      # Ecuentro Affinities.
      #    - Si es hijo, marco para expirar.
      #    - Si es padre, marco para expirar



      # EJEMPLO: Persona A es padre de B por mismo DNI
      # cambio DNI a B. Creo Issue para comunicar a compliance
      # para expirar affinity same_person de A a B.

  end
end