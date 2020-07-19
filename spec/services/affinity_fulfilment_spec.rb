require 'rails_helper'

describe Util::AffinityFulfilment do
  describe '.call' do

    it 'fulfil a same_person AffinitySeed issue when found exact matches' do
      # A. Exact match
      #            +------------------------+
      #   Before:  | Person_A (id number_a) |
      #            +------------------------+

      #   Action: a Person_B has set a new id to number_a

      #   After: Issue is created in Person_A with affinity same_person
      #         with realted_person: Person_B.
      #         If issue is approved:
      #           +------------------------+    +-----------------------+
      #           | Person_A (id number_a) | -> | Person_B(id number_a) |
      #           +------------------------+    +-----------------------+
      person_a = create_person_with_identification('number_a')
      person_b = create_person_with_identification('number_a')

      AffinityFinder::SamePerson.call(person_b)

      expect do
        person_a.issues.last.approve!
      end.to change{person_a.affinities.count}.by(1)
    end

    it 'fulfil a new same_person AffinitySeed on a person with existing affinity relation' do
      # B. Partial match with existing relation

      #            +----------------------+    +---------------------+
      #   Before:  | Person_A (id ABC123) | -> | Person_B(id ABC123) |
      #            +----------------------+    +---------------------+

      #   Action: a Person_C has set a new id to BC12

      #   After: Issue is created in Person_A with affinity same_person
      #         with realted_person: Person_C
      #         If issue is approved:
      #           +----------------------+     +----------------------+
      #           | Person_A (id ABC123) | --> | Person_B (id ABC123) |
      #           +----------------------+\    +----------------------+
      #                                    \   +--------------------+
      #                                     -> | Person_C (id BC12) |
      #                                        +--------------------+

      person_a = create_person_with_identification('ABC123')
      person_b = create_person_with_identification('ABC123')
      AffinityFinder::SamePerson.call(person_b)
      person_a.issues.last.approve!

      person_c = create_person_with_identification('BC12')

      AffinityFinder::SamePerson.call(person_c)

      expect do
        person_a.issues.last.approve!
      end.to change{person_a.affinities.count}.by(1)

      expect(person_a.affinities.last).to have_attributes({
        related_person_id: person_c.id,
        affinity_kind_id: AffinityKind.find_by_code(:same_person).id
      })

      # C. Inverse partial match with existing relation

      #   Action: a Person_D has set a new id to XABC1234Z

      #   After: Issue is created in Person_A with affinity same_person
      #         with realted_person: Person_D

      person_d = create_person_with_identification('XABC1234Z')

      AffinityFinder::SamePerson.call(person_d)

      expect do
        person_a.issues.last.approve!
      end.to change{person_a.affinities.count}.by(1)

      expect(person_a.affinities.last).to have_attributes({
        related_person_id: person_d.id,
        affinity_kind_id: AffinityKind.find_by_code(:same_person).id
      })
    end

    it 'fulfil an archive affinity seed' do
      # D. Father with existing child change id and break relationship with child

      #            +----------------------+    +---------------------+
      #   Before:  | Person_A (id ABC123) | -> | Person_B(id ABC123) |
      #            +----------------------+    +---------------------+

      #   Action: Person_A has a new id DEF456

      #   After: Issue is created in Person_A to replace existing affinity with
      #          Person_B, setting archived_at attribute to issue created date
      #          If issue is approved:

      #            +----------------------+    +---------------------+
      #            | Person_A (id DEF456) |    | Person_B(id ABC123) |
      #            +----------------------+    +---------------------+
      person_a = create_person_with_identification('ABC123')
      person_b = create_person_with_identification('ABC123')
      AffinityFinder::SamePerson.call(person_b)
      person_a.issues.last.approve!

      current_same_person_affinity = person_a.affinities.last

      change_person_identification(person_a, 'DEF456')

      AffinityFinder::SamePerson.call(person_a)

      expect do
        person_a.issues.last.approve!
      end.to change{person_a.affinities.count}.by(-1)

      expect(person_b.related_affinities).to be_empty
    end

    it 'fulfil affinity with existing father' do
      # E. Person with existing same_person child change id, break relationship with child and
      #     found match with 3 persons with existing same_person affinity

      #             +----------------------+    +----------------------+
      #     Before: | Person_B (id ABC123) | -> | Person_C (id ABC123) |
      #             +----------------------+    +----------------------+

      #             +----------------------+    +----------------------+
      #             | Person_A (id DEF456) | -> | Person_D (id DEF456) |
      #             +----------------------+\   +----------------------+
      #                                      \   +-----------------------+
      #                                       -> | Person_E (id DEF456)  |
      #                                          +-----------------------+


      #     Action: Person_B has a new id DEF456

      #     After: Issue is created in Person_A with affinity same_person
      #           with realted_person: Person_B. On issue approval, Person_B relationship
      #           with Person_C will be archived

      #                                  +----------------------+
      #           If issue is approved:  | Person_C (id ABC123) |
      #                                  +----------------------+
      #             +----------------------+    +----------------------+
      #             | Person_A (id DEF456) | -> | Person_D (id DEF456) |
      #             +----------------------+\   +----------------------+
      #                                   \  \   +-------------------------+
      #                                    \  -> | Person_E (id DEF456)    |
      #                                     \    +-------------------------+
      #                                      \   +-------------------------+
      #                                       -> | Person_B (id DEF456)    |
      #                                          +-------------------------+

      person_a = create_person_with_identification('DEF456')
      person_b = create_person_with_identification('ABC123')
      person_c = create_person_with_identification('ABC123')
      person_d = create_person_with_identification('DEF456')
      person_e = create_person_with_identification('DEF456')

      AffinityFinder::SamePerson.call(person_a)
      person_a.issues[-1].approve!
      person_a.issues[-2].approve!
      AffinityFinder::SamePerson.call(person_b)
      person_b.issues.last.approve!

      change_person_identification(person_b, 'DEF456')
      person_b.reload

      expect do
        AffinityFinder::SamePerson.call(person_b)
      end.to change{Issue.count}.by(1)
      person_a.reload

      expect do
        person_a.issues.last.approve!
      end.to change{Issue.count}.by(1)

      expect(person_a.affinities.last).to have_attributes({
        related_person_id: person_b.id,
        affinity_kind_id: AffinityKind.find_by_code(:same_person).id
      })

      expect(person_c.related_affinities).to be_empty
    end

    it 'fulfil affinity with existing father as a father' do
      # F. Person with existing same_person affinity change id, break relationship with father and
      #   found match with 3 persons with existing same_person affinity. This Person is older than
      #   the matches

      #           +----------------------+    +----------------------+
      #   Before: | Person_A (id ABC123) | -> | Person_B (id ABC123) |
      #           +----------------------+    +----------------------+

      #           +----------------------+    +----------------------+
      #           | Person_C (id DEF456) | -> | Person_D (id DEF456) |
      #           +----------------------+\   +----------------------+
      #                                    \   +----------------------+
      #                                     -> | Person_E (id DEF456) |
      #                                        +----------------------+

      #   Action: Person_B has a new id DEF456

      #   After: Issue is created in Person_B with affinity same_person
      #         with Person_C. When this issue is approved, the existing relationship
      #         bettween C, D and E will be reorganized

      #                                +----------------------+
      #         If issue is approved:  | Person_C (id ABC123) |
      #                                +----------------------+
      #           +----------------------+    +----------------------+
      #           | Person_B (id DEF456) | -> | Person_C (id DEF456) |
      #           +----------------------+\   +----------------------+
      #                                 \  \   +-------------------------+
      #                                  \  -> | Person_D (id DEF456)    |
      #                                   \    +-------------------------+
      #                                    \   +-------------------------+
      #                                     -> | Person_E (id DEF456)    |
      #                                         +-------------------------+
      person_a = create_person_with_identification('ABC123')
      person_b = create_person_with_identification('ABC123')
      person_c = create_person_with_identification('DEF456')
      person_d = create_person_with_identification('DEF456')
      person_e = create_person_with_identification('DEF456')

      AffinityFinder::SamePerson.call(person_a)
      person_a.issues.last.approve!
      AffinityFinder::SamePerson.call(person_c)
      person_c.issues[-1].approve!
      person_c.issues[-2].approve!

      change_person_identification(person_b, 'DEF456')

      expect do
        AffinityFinder::SamePerson.call(person_b)
      end.to change{Issue.count}.by(1)

      issue = Issue.last
      expect(issue.person_id).to be(person_b.id)
      affinity_seed = issue.affinity_seeds.first
      affinity_kind = AffinityKind.find_by_code(:same_person)

      expect(affinity_seed).to have_attributes({
        related_person_id: person_c.id,
        affinity_kind_id: affinity_kind.id
      })
    end

    it 'fulfil affinity with another person breaking relationship with existing childrens' do
      # G. Father with existing childs change id and break relationship with childs and create new one

      #           +----------------------+    +---------------------+
      #   Before: | Person_A (id ABC123) | -> | Person_B(id ABC123) |
      #           +----------------------+    +---------------------+
      #                                    \   +----------------------+
      #                                     -> | Person_C (id ABC123) |
      #                                        +----------------------+
      #           +----------------------+
      #           | Person_D (id DEF456) |
      #           +----------------------+

      #   Action: Person_A has a new id DEF456

      #   After: Issue is created in Person_A with affinity same_person to Person_D

      #         If issue is approved:

      #           Person_B -> Person_C

      #           +----------------------+      +---------------------+
      #           | Person_A (id DEF456) |  ->  | Person_D(id DEF456) |
      #           +----------------------+      +---------------------+

      #   ALERT TO DISCUSS: Somehow we must archived existing relationship between A, B and C
      #                     and create new affinity between B and C (on issue approval)
      #                     Evaluar si hijos que quedan huerfanos tienen datos distintos (nombre/dni)
      #                     Nuevo caso (I) igual a este pero con relacion existente entre A y D con matcheo
      #                     por nombre y Person E con un DNI igual a A. A con 4 hijos (2 dni y 2 nombre)

      person_a = create_person_with_identification('ABC123')
      person_b = create_person_with_identification('ABC123')
      person_c = create_person_with_identification('ABC123')
      person_d = create_person_with_identification('DEF456')

      AffinityFinder::SamePerson.call(person_a)
      person_a.issues[-1].approve!
      person_a.issues[-2].approve!

      change_person_identification(person_a, 'DEF456')
      person_a.reload

      expect do
        AffinityFinder::SamePerson.call(person_a)
      end.to change{Issue.count}.by(1)

      issue = Issue.last
      expect(issue.person_id).to be(person_a.id)
      affinity_seed = issue.affinity_seeds.first
      affinity_kind = AffinityKind.find_by_code(:same_person)

      expect(affinity_seed).to have_attributes({
        related_person_id: person_d.id,
        affinity_kind_id: affinity_kind.id
      })
    end

    it 'fulfil affinity with existing children' do
      # H. New Person with name affinity to an id affinity child

      #           +----------------------+    +---------------------+
      #  Before:  | Person_A (id ABC123) | -> | Person_B(id ABC123) |
      #           |  (name John P.)      |    |  (name: Juan Perez) |
      #           +----------------------+    +---------------------+

      #   Action: Person_C is created with id DEF456 and name Juan Perez

      #   After: Issue is created in Person_B with affinity same_person (name) to Person_C

      #         If issue is approved:

      #           +----------------------+    +---------------------+
      #           | Person_A (id ABC123) | -> | Person_B(id ABC123) |
      #           |  (name John P.)      |    |  (name: Juan Perez) |
      #           +----------------------+    +---------------------+
      #                                   \   +----------------------+
      #                                    -> | Person_C (id DEF456) |
      #                                       |  (name: Juan Perez)  |
      #                                       +----------------------+

      person_a = create_person_with_identification('ABC123')
      person_b = create_person_with_identification('ABC123')

      AffinityFinder::SamePerson.call(person_a)
      person_a.issues.last.approve!

      change_person_name(person_a, 'John', 'P.')
      change_person_name(person_b, 'Juan', 'Perez')

      person_c = create_natural_person_with_docket('Juan', 'Perez')

      expect do
        AffinityFinder::SamePerson.call(person_c)
      end.to change{Issue.count}.by(1)

      issue = Issue.last
      expect(issue.person_id).to be(person_b.id)
      affinity_seed = issue.affinity_seeds.first
      affinity_kind = AffinityKind.find_by_code(:same_person)

      expect(affinity_seed).to have_attributes({
        related_person_id: person_c.id,
        affinity_kind_id: affinity_kind.id
      })
    end

    it 'fulfil affinity with new children' do
      # I. Father with existing childs change name and break relationship with one child and create new relationship

      #             +---------------------------------+    +---------------------+
      #     Before: | Person_A (id ABC123, name John) | -> | Person_B(id ABC123) |
      #             +---------------------------------+    +---------------------+
      #                                       \   +----------------------+
      #                                        -> | Person_C (name john) |
      #                                           +----------------------+
      #             +----------------------+
      #             | Person_D (name jona) |
      #             +----------------------+

      #     Action: Person_A has a new name Jona

      #     After: Issue is created in Person_A with affinity same_person to Person_D

      #           If issue is approved:

      #             Person_B -> Person_C

      #             +---------------------------------+    +---------------------+
      #             | Person_A (id ABC123, name Jona) | -> | Person_B(id ABC123) |
      #             +---------------------------------+    +---------------------+
      #                                       \   +----------------------+
      #                                        -> | Person_D (name jona) |
      #                                           +----------------------+

      #             +----------------------+
      #             | Person_C (name john) |
      #             +----------------------+

      #     ALERT TO CHECK: Somehow we must archived existing relationship between A and C when issue is approved

      person_a = create_person_with_identification('ABC123')
      person_b = create_person_with_identification('ABC123')
      AffinityFinder::SamePerson.call(person_a)
      person_a.issues.last.approve!

      person_c = create_natural_person_with_docket('John', 'Doe')

      change_person_name(person_a, 'John', 'Doe')
      person_a.reload

      AffinityFinder::SamePerson.call(person_c)

      person_a.issues.last.approve!

      person_d = create_natural_person_with_docket('Jona', 'Brother')

      change_person_name(person_a, 'Jona', 'Brother')

      person_a.reload

      expect do
        AffinityFinder::SamePerson.call(person_a)
      end.to change{Issue.count}.by(1)

      issue = Issue.last
      expect(issue.person_id).to be(person_a.id)
      affinity_seed = issue.affinity_seeds.first
      affinity_kind = AffinityKind.find_by_code(:same_person)

      expect(affinity_seed).to have_attributes({
        related_person_id: person_d.id,
        affinity_kind_id: affinity_kind.id
      })
    end

    it 'fulfil affinity linked with existing relationship' do
      # J. Child with relation by name change id and create new relationship with existing relations

      #  Before:  +----------------------+       +----------------------+
      #           | Person_A (id ABC123) |  ->   | Person_B (id ABC123) |
      #           +----------------------+       +----------------------+

      #           +---------------------------------+    +---------------------+
      #           | Person_D (id DEF456, name John) | -> | Person_E(id DEF456) |
      #           +---------------------------------+    +---------------------+
      #                                     \   +---------------------------------+
      #                                      -> | Person_F (name john, id GHI789) |
      #                                         +---------------------------------+


      #   Action: Person_F has a new id ABC123

      #   After: Issue is created in Person_A with affinity same_person to Person_F?

      #         If issue is approved:
      #           +----------------------+       +----------------------+
      #           | Person_A (id ABC123) |  ->   | Person_B (id ABC123) |
      #           +----------------------+       +----------------------+
      #                             \   \        +---------------------------------+
      #                              \    -----> | Person_D (id DEF456, name John) |
      #                               \          +---------------------------------+
      #                                \
      #                                 \         +---------------------+
      #                                  \ -----> | Person_E(id DEF456) |
      #                                   \       +---------------------+
      #                                    \   +---------------------------------+
      #                                     -> | Person_F (name john, id ABC123) |
      #                                        +---------------------------------+

      #   ALERT TO CHECK: Somehow we must archived existing relationship between A and C when issue is approved

      person_a = create_person_with_identification('ABC123')
      person_b = create_person_with_identification('ABC123')
      AffinityFinder::SamePerson.call(person_a)
      person_a.issues.last.approve!

      person_d = create_person_with_identification('DEF456')
      person_e = create_person_with_identification('DEF456')
      AffinityFinder::SamePerson.call(person_d)
      person_d.issues.last.approve!

      person_f = create_person_with_identification('GHI789')

      change_person_name(person_d, 'John', '')
      change_person_name(person_f, 'John', '')

      person_d.reload
      person_f.reload

      expect do
        AffinityFinder::SamePerson.call(person_d)
      end.to change{person_d.issues.count}.by(1)

      person_d.issues.last.approve!

      change_person_identification(person_f, 'ABC123')

      expect do
        AffinityFinder::SamePerson.call(person_f)
      end.to change{Issue.count}.by(1)

      issue = Issue.last
      expect(issue.person_id).to be(person_a.id)
      affinity_seed = issue.affinity_seeds.first
      affinity_kind = AffinityKind.find_by_code(:same_person)

      expect(affinity_seed).to have_attributes({
        related_person_id: person_f.id,
        affinity_kind_id: affinity_kind.id
      })
    end
  end
end

def create_person_with_identification(number)
  seed = create(:full_natural_person_identification_seed_with_person,
                  number: number)
  seed.issue.approve!
  seed.issue.person.reload
end

def change_person_identification(person, number)
  issue = create(:basic_issue, person_id: person.id)
  create(
    :full_natural_person_identification_seed,
    issue: issue,
    number: number,
    replaces: person.identifications.last
  )
  issue.approve!
end

def change_person_name(person, first_name, last_name)
  seed = create(
           :full_natural_docket_seed_with_issue,
           person: person,
           first_name: first_name,
           last_name: last_name
  )

  seed.issue.reload.approve!
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
           Person_B, setting archived_at attribute to issue created date
           If issue is approved:

             +----------------------+    +---------------------+
             | Person_A (id DEF456) |    | Person_B(id ABC123) |
             +----------------------+    +---------------------+

  E. Person with existing same_person child change id, break relationship with child and
     found match with 3 persons with existing same_person affinity

             +----------------------+    +----------------------+
    Before:  | Person_B (id ABC123) | -> | Person_C (id ABC123) |
             +----------------------+    +----------------------+

             +----------------------+    +----------------------+
             | Person_A (id DEF456) | -> | Person_D (id DEF456) |
             +----------------------+\   +----------------------+
                                      \   +-----------------------+
                                       -> | Person_E (id DEF456)  |
                                          +-----------------------+


    Action: Person_B has a new id DEF456

    After: Issue is created in Person_A with affinity same_person
           with realted_person: Person_B. On issue approval, Person_B relationship
           with Person_C will be archived

                                  +----------------------+
           If issue is approved:  | Person_C (id ABC123) |
                                  +----------------------+
             +----------------------+    +----------------------+
             | Person_A (id DEF456) | -> | Person_D (id DEF456) |
             +----------------------+\   +----------------------+
                                   \  \   +-------------------------+
                                    \  -> | Person_E (id DEF456)    |
                                     \    +-------------------------+
                                      \   +-------------------------+
                                       -> | Person_B (id DEF456)    |
                                          +-------------------------+

  F. Person with existing same_person affinity change id, break relationship with father and
     found match with 3 persons with existing same_person affinity. This Person is older than
     the matches

             +----------------------+    +----------------------+
    Before:  | Person_A (id ABC123) | -> | Person_B (id ABC123) |
             +----------------------+    +----------------------+

             +----------------------+    +----------------------+
             | Person_C (id DEF456) | -> | Person_D (id DEF456) |
             +----------------------+\   +----------------------+
                                      \   +----------------------+
                                       -> | Person_E (id DEF456) |
                                          +----------------------+

    Action: Person_B has a new id DEF456

    After: Issue is created in Person_B with affinity same_person
           with Person_C. When this issue is approved, the existing relationship
           bettween C, D and E will be reorganized

                                  +----------------------+
           If issue is approved:  | Person_C (id ABC123) |
                                  +----------------------+
             +----------------------+    +----------------------+
             | Person_B (id DEF456) | -> | Person_C (id DEF456) |
             +----------------------+\   +----------------------+
                                   \  \   +-------------------------+
                                    \  -> | Person_D (id DEF456)    |
                                     \    +-------------------------+
                                      \   +-------------------------+
                                       -> | Person_E (id DEF456)    |
                                          +-------------------------+

  G. Father with existing childs change id and break relationship with childs and create new one

             +----------------------+    +---------------------+
    Before:  | Person_A (id ABC123) | -> | Person_B(id ABC123) |
             +----------------------+    +---------------------+
                                      \   +----------------------+
                                       -> | Person_C (id ABC123) |
                                          +----------------------+
             +----------------------+
             | Person_D (id DEF456) |
             +----------------------+

    Action: Person_A has a new id DEF456

    After: Issue is created in Person_A with affinity same_person to Person_D

           If issue is approved:

             Person_B -> Person_C

             +----------------------+      +---------------------+
             | Person_A (id DEF456) |  ->  | Person_D(id DEF456) |
             +----------------------+      +---------------------+

    ALERT TO DISCUSS: Somehow we must archived existing relationship between A, B and C
                      and create new affinity between B and C (on issue approval)
                      Evaluar si hijos que quedan huerfanos tienen datos distintos (nombre/dni)
                      Nuevo caso (I) igual a este pero con relacion existente entre A y D con matcheo
                      por nombre y Person E con un DNI igual a A. A con 4 hijos (2 dni y 2 nombre)

  H. New Person with name affinity to an id affinity child

             +----------------------+    +---------------------+
    Before:  | Person_A (id ABC123) | -> | Person_B(id ABC123) |
             |  (name John P.)      |    |  (name: Juan Perez) |
             +----------------------+    +---------------------+

    Action: Person_C is created with id DEF456 and name Juan Perez

    After: Issue is created in Person_B with affinity same_person (name) to Person_C

           If issue is approved:

             +----------------------+    +---------------------+
             | Person_A (id ABC123) | -> | Person_B(id ABC123) |
             |  (name John P.)      |    |  (name: Juan Perez) |
             +----------------------+    +---------------------+
                                     \   +----------------------+
                                      -> | Person_C (id DEF456) |
                                         |  (name: Juan Perez)  |
                                         +----------------------+

  I. Father with existing childs change name and break relationship with one child and create new relationship

             +---------------------------------+    +---------------------+
    Before:  | Person_A (id ABC123, name John) | -> | Person_B(id ABC123) |
             +---------------------------------+    +---------------------+
                                      \   +----------------------+
                                       -> | Person_C (name john) |
                                          +----------------------+
             +----------------------+
             | Person_D (name jona) |
             +----------------------+

    Action: Person_A has a new name Jona

    After: Issue is created in Person_A with affinity same_person to Person_D

           If issue is approved:

             Person_B -> Person_C

             +---------------------------------+    +---------------------+
             | Person_A (id ABC123, name Jona) | -> | Person_B(id ABC123) |
             +---------------------------------+    +---------------------+
                                      \   +----------------------+
                                       -> | Person_D (name jona) |
                                          +----------------------+

             +----------------------+
             | Person_C (name john) |
             +----------------------+

    ALERT TO CHECK: Somehow we must archived existing relationship between A and C when issue is approved

  J. Child with relation by name change id and create new relationship with existing relations

    Before:  +----------------------+       +----------------------+
             | Person_A (id ABC123) |  ->   | Person_B (id ABC123) |
             +----------------------+       +----------------------+

             +---------------------------------+    +---------------------+
             | Person_D (id DEF456, name John) | -> | Person_E(id DEF456) |
             +---------------------------------+    +---------------------+
                                      \   +---------------------------------+
                                       -> | Person_F (name john, id GHI789) |
                                          +---------------------------------+


    Action: Person_F has a new id ABC123

    After: Issue is created in Person_A with affinity same_person to Person_F?

           If issue is approved:
             +----------------------+       +----------------------+
             | Person_A (id ABC123) |  ->   | Person_B (id ABC123) |
             +----------------------+       +----------------------+
                               \   \        +---------------------------------+
                                \    -----> | Person_D (id DEF456, name John) |
                                 \          +---------------------------------+
                                  \
                                   \         +---------------------+
                                    \ -----> | Person_E(id DEF456) |
                                     \       +---------------------+
                                      \   +---------------------------------+
                                       -> | Person_F (name john, id ABC123) |
                                          +---------------------------------+

    ALERT TO CHECK: Somehow we must archived existing relationship between A and C when issue is approved

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