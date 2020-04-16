require 'rails_helper'

describe AffinityFinder::SamePerson do
  describe '.with_matched_id_numbers' do
    it 'matches exact numbers' do
      create( :full_natural_person_identification,
              person: person_a, number: 'number_a')
      create( :full_natural_person_identification,
              person: person_b, number: 'number_a')

      person_b.reload

      expect(AffinityFinder::SamePerson.with_matched_id_numbers(person_b)).to eq(
        [person_a.id]
      )

      create( :full_natural_person_identification,
        person: person_b, number: 'num_d')
      create( :full_natural_person_identification,
        person: person_c, number: 'num_d')
      create( :full_natural_person_identification,
        person: person_d, number: 'num_d')

      person_c.reload

      expect(AffinityFinder::SamePerson.with_matched_id_numbers(person_c)).to eq(
        [person_b.id, person_d.id]
      )
    end

    it 'matches when person identification are contained in another record' do
      person_a = create_person_with_identification('number_a')
      person_b = create_person_with_identification('The_number_a_contained')

      expect(AffinityFinder::SamePerson.with_matched_id_numbers(person_b)).to eq(
        [person_a.id]
      )

      add_id_to_person(person_b, 'num_d')
      person_c = create_person_with_identification('a num_d contained again')
      person_d = create_person_with_identification('the num_d contained')

      expect(AffinityFinder::SamePerson.with_matched_id_numbers(person_c)).to eq(
        [person_b.id, person_d.id]
      )
    end

    it 'matches when another record number are contained in person identification'
    it 'matches when person identification are at beginning of id in another record'
    it 'matches when another record number are at beginning of person identification'
    it 'matches when person identification are at the end of id in another record'
    it 'matches when another record number are at the end of person identification'
    it 'returns empty array when no matches are found'
  end

  describe '.with_matched_names' do
    it 'matches exact name and surname'
    it 'matches when person name are contained in another record'
    it 'matches when another record name are contained in person name'
    it 'returns empty array when no matches are found'
  end

  describe '.call' do
    it 'creates a same_person AffinitySeed issue when found matches' do
        person.reload
        expect do
            AffinityFinder::SamePerson.call(person)
        end.to change { Issue.count }.by(1)
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
  seed_a = create(:full_natural_person_identification_seed_with_person,
                  number: number)
  seed_a.issue.approve!
  seed_a.issue.person.reload
end

def add_id_to_person(person, number)
  seed = create(:full_natural_person_identification_seed_with_person,
    person: person,
    number: number)
  seed.issue.approve!
  person.reload
end