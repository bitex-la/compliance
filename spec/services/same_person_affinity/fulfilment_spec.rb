require 'rails_helper'

describe SamePersonAffinity::Fulfilment do
  describe '.call' do

    it 'fulfil a same_person AffinitySeed issue when found exact matches' do
      # A. Exact match
      #            +------------------------+
      #   Before:  | Person_A (id number_a) |
      #            +------------------------+
      person_a = create_person_with_identification('number_a')

      #   Action: a Person_B has set a new id to number_a
      person_b = create_person_with_identification('number_a')

      #   After: Issue is created in Person_A with affinity same_person
      #         with realted_person: Person_B.
      #         If issue is approved:
      #           +------------------------+    +-----------------------+
      #           | Person_A (id number_a) | -> | Person_B(id number_a) |
      #           +------------------------+    +-----------------------+
      SamePersonAffinity::Finder.call(person_b)

      expect do
        person_a.issues.last.approve!
      end.to change{person_a.affinities.count}.by(1)

      expect(person_a.affinities.pluck(:related_person_id)).to match_array([
        person_b.id
      ])
    end

    it 'fulfil a new same_person AffinitySeed on a person with existing affinity relation' do
      # B. Partial match with existing relation

      #            +----------------------+    +---------------------+
      #   Before:  | Person_A (id ABC123) | -> | Person_B(id ABC123) |
      #            +----------------------+    +---------------------+
      person_a = create_person_with_identification('ABC123')
      person_b = create_person_with_identification('ABC123')
      SamePersonAffinity::Finder.call(person_b)
      person_a.issues.last.approve!

      #   Action: a Person_C has set a new id to BC12
      person_c = create_person_with_identification('BC12')


      #   After: Issue is created in Person_A with affinity same_person
      #         with realted_person: Person_C
      #         If issue is approved:
      #           +----------------------+     +----------------------+
      #           | Person_A (id ABC123) | --> | Person_B (id ABC123) |
      #           +----------------------+\    +----------------------+
      #                                    \   +--------------------+
      #                                     -> | Person_C (id BC12) |
      #                                        +--------------------+
      SamePersonAffinity::Finder.call(person_c)

      expect do
        person_a.issues.last.approve!
      end.to change{person_a.affinities.count}.by(1)

      expect(person_a.affinities.pluck(:related_person_id)).to match_array([
        person_b.id, person_c.id
      ])

      expect(person_a.affinities.pluck(:auto_created)).to match_array([
        true, true
      ])

      expect(person_a.affinities.first.issue.note_seeds.first.title).to eq('auto created')

      # C. Inverse partial match with existing relation

      #   Action: a Person_D has set a new id to XABC1234Z

      #   After: Issue is created in Person_A with affinity same_person
      #         with realted_person: Person_D

      person_d = create_person_with_identification('XABC1234Z')

      SamePersonAffinity::Finder.call(person_d)

      expect do
        person_a.issues.last.approve!
      end.to change{person_a.affinities.count}.by(1)

      expect(person_a.affinities.pluck(:related_person_id)).to match_array([
        person_b.id, person_c.id, person_d.id
      ])
    end

    it 'fulfil an archive affinity seed' do
      # D. Father with existing child change id and break relationship with child

      #            +----------------------+    +---------------------+
      #   Before:  | Person_A (id ABC123) | -> | Person_B(id ABC123) |
      #            +----------------------+    +---------------------+
      person_a = create_person_with_identification('ABC123')
      person_b = create_person_with_identification('ABC123')
      SamePersonAffinity::Finder.call(person_b)
      person_a.issues.last.approve!

      #   Action: Person_A has a new id DEF456
      change_person_identification(person_a, 'DEF456')

      #   After: Issue is created in Person_A to replace existing affinity with
      #          Person_B, setting archived_at attribute to issue created date
      #          If issue is approved:

      #            +----------------------+    +---------------------+
      #            | Person_A (id DEF456) |    | Person_B(id ABC123) |
      #            +----------------------+    +---------------------+
      SamePersonAffinity::Finder.call(person_a)

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
      person_a = create_person_with_identification('DEF456')
      person_b = create_person_with_identification('ABC123')
      person_c = create_person_with_identification('ABC123')
      person_d = create_person_with_identification('DEF456')
      person_e = create_person_with_identification('DEF456')

      SamePersonAffinity::Finder.call(person_a)
      person_a.issues[-1].approve!
      person_a.issues[-2].approve!
      SamePersonAffinity::Finder.call(person_b)
      person_b.issues.last.approve!

      #     Action: Person_B has a new id DEF456
      change_person_identification(person_b, 'DEF456')
      person_b.reload

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
      expect do
        SamePersonAffinity::Finder.call(person_b)
      end.to change{Issue.count}.by(1)
      person_a.reload

      expect do
        person_a.issues.last.approve!
      end.to change{Issue.count}.by(1)

      person_a.reload

      expect(person_a.affinities.pluck(:related_person_id)).to match_array([
        person_d.id, person_e.id, person_b.id
      ])

      person_c.reload

      expect(person_c.related_affinities).to be_empty
      expect(person_c.affinities).to be_empty
      expect(person_b.affinities).to be_empty
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
      person_a = create_person_with_identification('ABC123')
      person_b = create_person_with_identification('ABC123')
      person_c = create_person_with_identification('DEF456')
      person_d = create_person_with_identification('DEF456')
      person_e = create_person_with_identification('DEF456')

      SamePersonAffinity::Finder.call(person_a)
      person_a.issues.last.approve!
      SamePersonAffinity::Finder.call(person_c)
      person_c.issues[-1].approve!
      person_c.issues[-2].approve!

      #   Action: Person_B has a new id DEF456
      change_person_identification(person_b, 'DEF456')

      #   After: Issue is created in Person_B with affinity same_person
      #         with Person_C. When this issue is approved, the existing relationship
      #         bettween C, D and E will be reorganized

      #                                +----------------------+
      #         If issue is approved:  | Person_A (id ABC123) |
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
      SamePersonAffinity::Finder.call(person_b)

      person_b.reload
      expect do
        person_b.issues.last.approve!
      end.to change{Issue.count}.by(5)

      person_b.reload
      expect(person_b.related_affinities).to be_empty

      person_c.reload
      expect(person_c.affinities).to be_empty

      person_a.reload
      expect(person_a.affinities).to be_empty
      expect(person_a.related_affinities).to be_empty

      person_b.reload
      expect(person_b.affinities.pluck(:related_person_id)).to match_array([
        person_c.id, person_d.id, person_e.id
      ])
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
      person_a = create_person_with_identification('ABC123')
      person_b = create_person_with_identification('ABC123')
      person_c = create_person_with_identification('ABC123')
      person_d = create_person_with_identification('DEF456')

      SamePersonAffinity::Finder.call(person_a)

      person_a.reload
      person_a.issues[-1].approve!
      person_a.issues[-2].approve!

      #   Action: Person_A has a new id DEF456
      change_person_identification(person_a, 'DEF456')
      person_a.reload

      #   After: Issue is created in Person_A with affinity same_person to Person_D

      #         If issue is approved:

      #           Person_B -> Person_C

      #           +----------------------+      +---------------------+
      #           | Person_A (id DEF456) |  ->  | Person_D(id DEF456) |
      #           +----------------------+      +---------------------+
      SamePersonAffinity::Finder.call(person_a)
      person_a.reload

      expect do
        person_a.issues.last.approve!
      end.to change{Issue.count}.by(3)
      person_a.reload

      expect(person_a.affinities.pluck(:related_person_id)).to match_array([
        person_d.id
      ])
      person_b.reload

      expect(person_b.related_affinities).to be_empty
      expect(person_b.affinities.pluck(:related_person_id)).to match_array([
        person_c.id
      ])
    end

    it 'fulfil affinity with existing children' do
      # H. New Person with name affinity to an id affinity child

      #           +----------------------+    +---------------------+
      #  Before:  | Person_A (id ABC123) | -> | Person_B(id ABC123) |
      #           |  (name John P.)      |    |  (name: Juan Perez) |
      #           +----------------------+    +---------------------+
      person_a = create_person_with_identification('ABC123')
      person_b = create_person_with_identification('ABC123')

      SamePersonAffinity::Finder.call(person_a)
      person_a.issues.last.approve!

      change_person_name(person_a, 'John', 'P.')
      change_person_name(person_b, 'Juan', 'Perez')

      #   Action: Person_C is created with id DEF456 and name Juan Perez
      person_c = create_natural_person_with_docket('Juan', 'Perez')

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
      SamePersonAffinity::Finder.call(person_c)
      person_b.reload

      expect do
        person_b.issues.last.approve!
      end.to change{Issue.count}.by(2)

      person_b.reload
      expect(person_b.affinities).to be_empty

      person_a.reload
      expect(person_a.affinities.pluck(:related_person_id)).to match_array([
        person_b.id, person_c.id
      ])
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
      person_a = create_person_with_identification('ABC123')
      person_b = create_person_with_identification('ABC123')
      SamePersonAffinity::Finder.call(person_a)
      person_a.issues.last.approve!
      person_c = create_natural_person_with_docket('John', 'Doe')

      change_person_name(person_a, 'John', 'Doe')
      person_a.reload

      SamePersonAffinity::Finder.call(person_c)

      person_a.issues.last.approve!

      person_d = create_natural_person_with_docket('Jona', 'Brother')


      #     Action: Person_A has a new name Jona
      change_person_name(person_a, 'Jona', 'Brother')
      person_a.reload

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
      SamePersonAffinity::Finder.call(person_a)

      person_a.reload
      expect do
        person_a.issues.last.approve!
      end.to change{Issue.count}.by(1)

      person_a.reload
      expect(person_a.affinities.pluck(:related_person_id)).to match_array([
        person_b.id, person_d.id
      ])

      person_c.reload
      expect(person_c.related_affinities).to be_empty
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
      person_a = create_person_with_identification('ABC123')
      person_b = create_person_with_identification('ABC123')
      SamePersonAffinity::Finder.call(person_a)
      person_a.issues.last.approve!

      person_d = create_person_with_identification('DEF456')
      person_e = create_person_with_identification('DEF456')
      SamePersonAffinity::Finder.call(person_d)
      person_d.issues.last.approve!

      person_f = create_person_with_identification('GHI789')

      change_person_name(person_d, 'John', '')
      change_person_name(person_f, 'John', '')

      person_d.reload
      person_f.reload

      SamePersonAffinity::Finder.call(person_d)
      person_d.issues.last.approve!

      #   Action: Person_F has a new id ABC123
      change_person_identification(person_f, 'ABC123')
      person_f.reload

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
      expect do
        SamePersonAffinity::Finder.call(person_f)
      end.to change{person_a.issues.count}.by(1)

      person_a.reload
      expect do
        person_a.issues.last.approve!
      end.to change{Issue.count}.by(4)

      person_a.reload
      expect(person_a.affinities.pluck(:related_person_id)).to match_array([
        person_b.id, person_d.id, person_e.id, person_f.id
      ])

      person_d.reload
      expect(person_d.affinities).to be_empty
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
