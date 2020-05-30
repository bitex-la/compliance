require 'rails_helper'

describe AffinityFinder::SamePerson do
  describe '.with_matched_id_numbers' do
    it 'matches exact numbers' do
      person_a = create_person_with_identification('number_a')
      person_b = create_person_with_identification('number_a')

      expect(AffinityFinder::SamePerson.with_matched_id_numbers(person_b)).to eq(
        [person_a.id]
      )

      add_id_to_person(person_b, 'num_d')
      person_c = create_person_with_identification('num_d')
      person_d = create_person_with_identification('num_d')

      expect(AffinityFinder::SamePerson.with_matched_id_numbers(person_c)).to match_array(
        [person_b.id, person_d.id]
      )
    end

    it 'matches when person identification are contained in another record' do
      person_a = create_person_with_identification('number_a')
      person_b = create_person_with_identification('The_number_a_contained')

      expect(AffinityFinder::SamePerson.with_matched_id_numbers(person_b)).to eq(
        [person_a.id]
      )

      add_id_to_person(person_b, 'num_b')
      person_c = create_person_with_identification('a num_b contained again')
      person_d = create_person_with_identification('the num_b inside')

      expect(AffinityFinder::SamePerson.with_matched_id_numbers(person_b)).to match_array(
        [person_a.id, person_c.id, person_d.id]
      )
    end

    it 'matches when person id number are at beginning of id number in another record' do
      person_a = create_person_with_identification('num a and other stuff')
      person_b = create_person_with_identification('num a')
      person_c = create_person_with_identification('num c')

      expect(AffinityFinder::SamePerson.with_matched_id_numbers(person_b)).to eq(
        [person_a.id]
      )
    end

    it 'matches when another record number are at beginning of person id number' do
      person_a = create_person_with_identification('num a')
      person_b = create_person_with_identification('num a and other stuff')
      person_c = create_person_with_identification('num c')

      expect(AffinityFinder::SamePerson.with_matched_id_numbers(person_b)).to eq(
        [person_a.id]
      )
    end

    it 'matches when person id number are at the end of id number in another record' do
      person_a = create_person_with_identification('ends with num a')
      person_b = create_person_with_identification('num a')
      person_c = create_person_with_identification('num c')

      expect(AffinityFinder::SamePerson.with_matched_id_numbers(person_b)).to eq(
        [person_a.id]
      )
    end

    it 'matches when another record number are at the end of person identification' do
      person_a = create_person_with_identification('num a')
      person_b = create_person_with_identification('ends with num a')
      person_c = create_person_with_identification('num c')

      expect(AffinityFinder::SamePerson.with_matched_id_numbers(person_b)).to eq(
        [person_a.id]
      )
    end

    it 'returns empty array when no matches are found' do
      person_a = create_person_with_identification('number_a')
      person_b = create_person_with_identification('number_b')

      expect(AffinityFinder::SamePerson.with_matched_id_numbers(person_b)).to eq(
        []
      )
    end
  end

  describe '.with_matched_names' do
    it 'matches exact name and surname' do
      # matches
      person_a = create_natural_person_with_docket('Juan', 'Perez')
      person_b = create_natural_person_with_docket('Juan', 'Perez')
      person_c = create_natural_person_with_docket('juan', 'perez')

      # no matches
      person_d = create_natural_person_with_docket('juana', 'perez')
      person_e = create_natural_person_with_docket('Juana', 'Molina')
      person_f = create_natural_person_with_docket('juan', 'pereza')


      legal_person_a = create_legal_person_with_docket('ACME', nil)
      legal_person_b = create_legal_person_with_docket('acme', nil)
      legal_person_c = create_legal_person_with_docket(nil, 'Apple Inc.')
      legal_person_d = create_legal_person_with_docket(nil, 'APPLE INC.')

      expect(AffinityFinder::SamePerson.with_matched_names(person_b)).to match_array(
        [person_a.id, person_c.id]
      )

      expect(AffinityFinder::SamePerson.with_matched_names(legal_person_b)).to eq(
        [legal_person_a.id]
      )

      expect(AffinityFinder::SamePerson.with_matched_names(legal_person_d)).to eq(
        [legal_person_c.id]
      )
    end

    it 'matches when person full name are a subset of another records' do
      person_a = create_natural_person_with_docket('Juan', 'Perez')
      person_b = create_natural_person_with_docket('Juan Antonio', 'Perez')
      person_c = create_natural_person_with_docket('Juan', 'Perez Gonzalez')
      person_d = create_natural_person_with_docket('Pedro Juan', 'García Perez')
      person_e = create_natural_person_with_docket('Not the Droid', 'U are looking for')

      expect(AffinityFinder::SamePerson.with_matched_names(person_a)).to match_array(
        [person_b.id, person_c.id, person_d.id]
      )
    end

    it 'matches when another records full name are a subset of person sub name' do
      person_a = create_natural_person_with_docket('Juan', 'Perez')
      person_b = create_natural_person_with_docket('Juan Antonio', 'Perez')
      person_c = create_natural_person_with_docket('antonio', 'juan Perez')

      expect(AffinityFinder::SamePerson.with_matched_names(person_b)).to match_array(
        [person_a.id, person_c.id]
      )
    end

    it 'returns empty array when no matches are found' do
      person_a = create_natural_person_with_docket('Juan', 'Perez')
      person_b = create_natural_person_with_docket('Juana', 'Molina')
      person_c = create_natural_person_with_docket('Juan Carlos', 'Molina')
      person_d = create_natural_person_with_docket('Juan Antonio', 'Molina')

      legal_person_a = create_legal_person_with_docket('Empresa', nil)
      legal_person_b = create_legal_person_with_docket('La Empresa', nil)

      legal_person_c = create_legal_person_with_docket(nil, 'ACME Inc.')
      legal_person_d = create_legal_person_with_docket(nil, 'ACME S.A.')

      expect(AffinityFinder::SamePerson.with_matched_names(person_b)).to eq(
        []
      )

      expect(AffinityFinder::SamePerson.with_matched_names(person_c)).to eq(
        []
      )

      expect(AffinityFinder::SamePerson.with_matched_names(legal_person_b)).to eq(
        []
      )

    end
  end

  describe '.related_persons' do
    it 'get matched affinity persons' do
      person_a = create(:basic_issue).reload.person
      person_b = create(:basic_issue).reload.person
      create(:full_affinity, person: person_b, affinity_kind_code: 'same_person')
      person_c = person_b.affinities.first.related_person

      expect(AffinityFinder::SamePerson.related_persons(
        [person_a.id, person_b.id]
      )).to match_array(
        [person_a.id, person_c.id]
      )
      expect(AffinityFinder::SamePerson.related_persons(
        [person_a.id, person_b.id, person_c.id]
      )).to match_array(
        [person_a.id, person_c.id]
      )

      expect(AffinityFinder::SamePerson.related_persons(
        [person_a.id, person_c.id]
      )).to match_array(
        [person_a.id, person_c.id]
      )
    end
  end

  describe '.call' do
    it 'creates a same_person AffinitySeed issue when found exact matches' do
      person_a = create_person_with_identification('number_a')
      person_b = create_person_with_identification('number_a')

      expect do
        AffinityFinder::SamePerson.call(person_b.id)
      end.to change{person_b.issues.count}.by(1)

      # check that no issue is created if another one is pending
      expect do
        # explain why this edge case (ie. create person_b)
        AffinityFinder::SamePerson.call(person_b.id)
      end.to change{person_b.issues.count}.by(0)
    end

    it 'creates a same_person AffinitySeed issue on children' do
      person_a = create_natural_person_with_docket('Juan', 'Molina')
      person_b = create_natural_person_with_docket('Juan Carlos', 'Molina')

      expect do
        # this could be triggered if person_a was
        # updated with a new natural_person_docket
        AffinityFinder::SamePerson.call(person_a.id)
      end.to change{person_b.issues.count}.by(1)

      affinity_b = person_b.issues.last.affinity_seeds.first
      affinity_kind = AffinityKind.find_by_code(:same_person)

      expect(affinity_b).to have_attributes({
        related_person_id: person_a.id,
        affinity_kind_id: affinity_kind.id
      })
    end

    # agregar caso con un padre y un hijo con affinity ya creado
    # y testeo person_a en donde la relación existente se archiva
    # hay que crear estado con issues aprobados y el affinity creado
    # puedo llamar al call para crear la issue y aprobarla
    # issue.add_seeds_replacing(fruits) unless params[:fruits].blank?
    # agregar el archived_at al affinity_seed
    # issue SIN APROBAR
    # crear luego dos issues con affinities hacia person_a

    it 'returns orphans same_person affinity persons' do
      # person_a -> person_b

      # person_a -> person_c

      # si no encuentra b ni c, devolver b y c
      # TODO: test with existing same_person relationships
      # TODO: test existing affinities invalidations
      # Do we have to use archived attribute in issues?
    end

    # TODO: Check edge case of an existing children related to a father by ID Number
    it 'found same-name affinity in children of a same-dni father' do
      # Fact: person_b -> person_c (same dni CUIL)
      # FOUND same_name affinity person_a -> person_c
      #
      # create issue in person_c related_to person_a?
      # what about person_b, father of existing affinity?
      #
      # Ideal outcome:
      # person_a -> person_b
      # person_a -> person_c
    end

    # Escenario person_a -> b -> c
    # call (b)


    # person_a (JUAN)(DNI 123) -> person_b (JUANA) (DNI 123)

    # person_c (JUANA)(DNI 456)




    # si encuentro relacion de affinity



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
    # PERSONA E DNI DIST (303) (NO HAY AFFINITY)
    # EDITO PERSONA
    # Ecuentro Affinities.
    #    - Si es hijo, marco para archivar.
    #    - Si es padre, marco para archivar.

    #  previo A -> B -> C   B -> D

    #  CAMBIO DNI DE B A 303
    #  ISSUE B -> E (same_person por DNI)
    #  ISSUE B seed affinity (archived_at fecha created_at de este issue)
    #          COPIAR ALGUNOS ATTR DEl fruit a reemplazar (ver ejemplos ya existentes)
    #          este seed tiene que reemplazar (replaces) al fruto B -> C
    #  ISSUE B seed affinity (archived_at fecha created_at de este issue)
    #          este seed tiene que reemplazar (replaces) al fruto B -> D
    #  ISSUE C -> D affinity same_person




    # EJEMPLO: Persona A es padre de B por mismo DNI
    # cambio DNI a B. Creo Issue para comunicar a compliance
    # para expirar affinity same_person de A a B.
  end
end

def create_person_with_identification(number)
  seed = create(:full_natural_person_identification_seed_with_person,
                  number: number)
  seed.issue.approve!
  seed.issue.person.reload
end

def create_natural_person_with_docket(first_name, last_name)
  seed = create(:full_natural_docket_seed_with_person,
                first_name: first_name, last_name: last_name)
  seed.issue.approve!
  seed.issue.person.reload
end

def create_legal_person_with_docket(commercial_name, legal_name)
  seed = create(:full_legal_entity_docket_seed_with_person,
                commercial_name: commercial_name, legal_name: legal_name)
  seed.issue.approve!
  seed.issue.person.reload
end

def add_id_to_person(person, number)
  seed = create(:full_natural_person_identification_seed_with_person,
    person: person,
    number: number)
  seed.issue.approve!
  person.reload
end

=begin
  Possible scenarios

  A. Exact match

             +----------------------+
    Before:  | Person_A (id ABC123) |
             +----------------------+

    Action: a Person_B has set a new id to ABC123

    After: Issue is created in Person_A with affinity same_person
           with realted_person: Person_B.
           If issue is approved:
             +----------------------+    +---------------------+
             | Person_A (id ABC123) | -> | Person_B(id ABC123) |
             +----------------------+    +---------------------+

  B. Partial match with existing relation

             +----------------------+    +---------------------+
    Before:  | Person_A (id ABC123) | -> | Person_B(id ABC123) |
             +----------------------+    +---------------------+

    Action: a Person_C has set a new id to BC12

    After: Issue is created in Person_A with affinity same_person
           with realted_person: Person_C
           If issue is approved:
             +----------------------+    +----------------------+
             | Person_A (id ABC123) | -> | Person_B (id ABC123) |
             +----------------------+\   +----------------------+
                                      \   +--------------------+
                                       -> | Person_C (id BC12) |
                                          +--------------------+

  C. Inverse partial match with existing relation

             +----------------------+    +---------------------+
    Before:  | Person_A (id ABC123) | -> | Person_B(id ABC123) |
             +----------------------+    +---------------------+

    Action: a Person_C has set a new id to XABC1234Z

    After: Issue is created in Person_A with affinity same_person
           with realted_person: Person_C
           If issue is approved:
             +----------------------+    +----------------------+
             | Person_A (id ABC123) | -> | Person_B (id ABC123) |
             +----------------------+\   +----------------------+
                                      \   +-------------------------+
                                       -> | Person_C (id XABC1234Z) |
                                          +-------------------------+

  D. Father with existing child change id and break relationship with child

             +----------------------+    +---------------------+
    Before:  | Person_A (id ABC123) | -> | Person_B(id ABC123) |
             +----------------------+    +---------------------+

    Action: Person_A has a new id DEF456

    After: Issue is created in Person_A to replace existing affinity with
           Person_B setting archived_at attribute to issue created date
           If issue is approved:

             +----------------------+    +---------------------+
             | Person_A (id DEF456) |    | Person_B(id ABC123) |
             +----------------------+    +---------------------+


=end

      # Crear issues por cada

      # all persons linked to this affinity_person
      # will be stored in order to bypass in next iteration


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