module AffinityFinder
    class SamePerson
      def self.call(person)
        matched_person_ids = Identification.where(
            "person_id <> :person_id AND
            replaced_by_id is NULL AND
            number LIKE any :numbers",
            person_id: person.id
            numbers: person.identifications.pluck(:number).map(|n| { "%#{n}%"})
        ).pluck(:person_id)

        # to refactor in a single query (subquery)
        # person.identifications.pluck(:number).map(|n| do
        #   Identification.where(
        #     "replaced_by_id is NULL AND (
        #     :number LIKE CONCAT('%', number, '%'))",
        #     number: n
        #   )
        # end)

        return nil unless found_ids

        # TRAER TODOS LOS AFFINITES SAME_PERSON de matched_person_ids

        matched_person_ids.sort.map{ |person_id|
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
        }


        # PERSONA A NOMBRE IGUAL DNI DISTINTO
        # PERSONA B NOMBRE IGUAL DNI DISTINTO
        # PERSONA C NOMBRE IGUAL PERSONA F  DNI IGUAL A B


        # PERSONA F NOMBRE DIST DNI DIST
        # PERSONA G NOMBRE DIST DNI IGUAL A G

        # Creates an issue with AffinitySeed affinity_kind_code: :same_person
        # expiration??
      end
    end
end