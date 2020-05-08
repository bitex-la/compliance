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

  describe '.call' do
    it 'creates a same_person AffinitySeed issue when found matches'

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