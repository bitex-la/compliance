require 'rails_helper'

describe SamePersonAffinity::Finder do
  describe '.with_matched_id_numbers' do
    it 'matches exact numbers' do
      person_a = create_person_with_identification('abc123')
      person_b = create_person_with_identification('abc123')

      expect(SamePersonAffinity::Finder.with_matched_id_numbers(person_b)).to eq(
        [person_a.id]
      )

      add_id_to_person(person_b, 'def456')
      person_c = create_person_with_identification('def456')
      person_d = create_person_with_identification('DEF456')

      expect(SamePersonAffinity::Finder.with_matched_id_numbers(person_c)).to match_array(
        [person_b.id, person_d.id]
      )
    end

    it 'matches when person identification are contained in another record' do
      person_a = create_person_with_identification('abc123')
      person_b = create_person_with_identification('zabc1234')

      expect(SamePersonAffinity::Finder.with_matched_id_numbers(person_b)).to eq(
        [person_a.id]
      )

      add_id_to_person(person_b, 'def456')
      person_c = create_person_with_identification('adef4567')
      person_d = create_person_with_identification('zdef4568')

      expect(SamePersonAffinity::Finder.with_matched_id_numbers(person_b)).to match_array(
        [person_a.id, person_c.id, person_d.id]
      )
    end

    it 'matches when person id number are at beginning of id number in another record' do
      person_a = create_person_with_identification('abc123Z')
      person_b = create_person_with_identification('abc123')
      person_c = create_person_with_identification('def456')

      expect(SamePersonAffinity::Finder.with_matched_id_numbers(person_b)).to eq(
        [person_a.id]
      )
    end

    it 'matches when another record number are at beginning of person id number' do
      person_a = create_person_with_identification('ABC123')
      person_b = create_person_with_identification('abc1234')
      person_c = create_person_with_identification('def456')

      expect(SamePersonAffinity::Finder.with_matched_id_numbers(person_b)).to eq(
        [person_a.id]
      )
    end

    it 'matches when person id number are at the end of id number in another record' do
      person_a = create_person_with_identification('z-abc123')
      person_b = create_person_with_identification('abc123')
      person_c = create_person_with_identification('def456')

      expect(SamePersonAffinity::Finder.with_matched_id_numbers(person_b)).to eq(
        [person_a.id]
      )
    end

    it 'matches when another record number are at the end of person identification' do
      person_a = create_person_with_identification('abc123')
      person_b = create_person_with_identification('zabc123')
      person_c = create_person_with_identification('def456')

      expect(SamePersonAffinity::Finder.with_matched_id_numbers(person_b)).to eq(
        [person_a.id]
      )
    end

    it 'returns empty array when no matches are found' do
      person_a = create_person_with_identification('abc123')
      person_b = create_person_with_identification('def456')

      expect(SamePersonAffinity::Finder.with_matched_id_numbers(person_b)).to eq(
        []
      )
    end

    it 'returns only persons in person_ids_filter' do
      person_a = create_person_with_identification('abc123')
      person_b = create_person_with_identification('abc123')
      person_c = create_person_with_identification('abc123')
      person_d = create_person_with_identification('def456')
      person_e = create_person_with_identification('abc12345')

      person_ids_filter = [person_c.id, person_d.id, person_e.id]
      expect(SamePersonAffinity::Finder.with_matched_id_numbers(person_a, person_ids_filter)).to match_array(
        [person_c.id, person_e.id]
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

      expect(SamePersonAffinity::Finder.with_matched_names(person_b)).to match_array(
        [person_a.id, person_c.id]
      )

      expect(SamePersonAffinity::Finder.with_matched_names(legal_person_b)).to eq(
        [legal_person_a.id]
      )

      expect(SamePersonAffinity::Finder.with_matched_names(legal_person_d)).to eq(
        [legal_person_c.id]
      )
    end

    it 'matches only persons in person_ids_filter' do
      # matches
      person_a = create_natural_person_with_docket('Juan', 'Perez')
      person_b = create_natural_person_with_docket('Juan', 'Perez')
      person_c = create_natural_person_with_docket('juan', 'perez')
      person_d = create_natural_person_with_docket('juan', 'perez')

      # no matches
      person_e = create_natural_person_with_docket('Juana', 'Molina')
      person_f = create_natural_person_with_docket('juan', 'pereza')


      legal_person_a = create_legal_person_with_docket('ACME', nil)
      legal_person_b = create_legal_person_with_docket('acme', nil)
      legal_person_c = create_legal_person_with_docket('acme', nil)
      legal_person_d = create_legal_person_with_docket('other company', nil)

      expect(SamePersonAffinity::Finder.with_matched_names(person_a, [person_c.id, person_f.id])).to match_array(
        [person_c.id]
      )

      expect(SamePersonAffinity::Finder.with_matched_names(legal_person_a, [legal_person_c.id, legal_person_d.id])).to match_array(
        [legal_person_c.id]
      )
    end

    it 'matches when person full name are a subset of another records' do
      person_a = create_natural_person_with_docket('Juan', 'Perez')
      person_b = create_natural_person_with_docket('Juan Antonio', 'Perez')
      person_c = create_natural_person_with_docket('Juan', 'Perez Gonzalez')
      person_d = create_natural_person_with_docket('Pedro Juan', 'García Perez')
      person_e = create_natural_person_with_docket('Not the Droid', 'U are looking for')

      expect(SamePersonAffinity::Finder.with_matched_names(person_a)).to match_array(
        [person_b.id, person_c.id, person_d.id]
      )
    end

    it 'matches when another records full name are a subset of person sub name' do
      person_a = create_natural_person_with_docket('Juan', 'Perez')
      person_b = create_natural_person_with_docket('Juan Antonio', 'Perez')
      person_c = create_natural_person_with_docket('antonio', 'juan Perez')

      expect(SamePersonAffinity::Finder.with_matched_names(person_b)).to match_array(
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

      expect(SamePersonAffinity::Finder.with_matched_names(person_b)).to eq(
        []
      )

      expect(SamePersonAffinity::Finder.with_matched_names(person_c)).to eq(
        []
      )

      expect(SamePersonAffinity::Finder.with_matched_names(legal_person_b)).to eq(
        []
      )

    end
  end

  describe '.call' do

    it 'creates a same_person AffinitySeed issue when found exact matches' do
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

      expect do
        SamePersonAffinity::Finder.call(person_b)
      end.to change{person_a.issues.count}.by(1)

      affinity_seed = person_a.issues.last.affinity_seeds.first
      affinity_kind = AffinityKind.same_person

      expect(affinity_seed).to have_attributes({
        related_person_id: person_b.id,
        affinity_kind_id: affinity_kind.id
      })

      # check that no issue is created if another one is pending
      expect do
        # explain why this edge case (ie. create person_b)
        SamePersonAffinity::Finder.call(person_b)
      end.to change{person_a.issues.count}.by(0)
    end

    it 'creates a new same_person AffinitySeed on a person with existing affinity relation' do
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
      expect do
        SamePersonAffinity::Finder.call(person_c)
      end.to change{person_a.issues.count}.by(1)

      # C. Inverse partial match with existing relation

      #   Action: a Person_D has set a new id to XABC1234Z
      person_d = create_person_with_identification('XABC1234Z')

      #   After: Issue is created in Person_A with affinity same_person
      #         with realted_person: Person_D
      expect do
        SamePersonAffinity::Finder.call(person_d)
      end.to change{person_a.issues.count}.by(1)
    end

    it 'breaks existing relationship with children' do
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
      expect do
        SamePersonAffinity::Finder.call(person_a)
      end.to change{person_a.issues.count}.by(1)

      affinity_seed = person_a.issues.last.affinity_seeds.first
      affinity_kind = AffinityKind.same_person

      expect(affinity_seed).to have_attributes({
        related_person_id: person_b.id,
        affinity_kind_id: affinity_kind.id,
        replaces: current_same_person_affinity
      })
    end

    it 'current father, creates new affinity with existing father' do
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

      issue = Issue.last
      expect(issue.person_id).to be(person_a.id)
      affinity_seed = issue.affinity_seeds.first
      affinity_kind = AffinityKind.same_person

      expect(affinity_seed).to have_attributes({
        related_person_id: person_b.id,
        affinity_kind_id: affinity_kind.id
      })
    end

    it 'current children, creates new affinity with existing father as a father' do
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
      expect do
        SamePersonAffinity::Finder.call(person_b)
      end.to change{Issue.count}.by(1)

      issue = Issue.last
      expect(issue.person_id).to be(person_b.id)
      affinity_seed = issue.affinity_seeds.first
      affinity_kind = AffinityKind.same_person

      expect(affinity_seed).to have_attributes({
        related_person_id: person_c.id,
        affinity_kind_id: affinity_kind.id
      })
    end

    it 'existing father creates new affinity with another person breaking relationship with existing childrens' do
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

      #   ALERT TO DISCUSS: Somehow we must archived existing relationship between A, B and C
      #                     and create new affinity between B and C (on issue approval)
      #                     Evaluar si hijos que quedan huerfanos tienen datos distintos (nombre/dni)
      #                     Nuevo caso (I) igual a este pero con relacion existente entre A y D con matcheo
      #                     por nombre y Person E con un DNI igual a A. A con 4 hijos (2 dni y 2 nombre)
      expect do
        SamePersonAffinity::Finder.call(person_a)
      end.to change{Issue.count}.by(1)

      issue = Issue.last
      expect(issue.person_id).to be(person_a.id)
      affinity_seed = issue.affinity_seeds.first
      affinity_kind = AffinityKind.same_person

      expect(affinity_seed).to have_attributes({
        related_person_id: person_d.id,
        affinity_kind_id: affinity_kind.id
      })
    end

    it 'person name matched with existing children' do
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
      expect do
        SamePersonAffinity::Finder.call(person_c)
      end.to change{Issue.count}.by(1)

      issue = Issue.last
      expect(issue.person_id).to be(person_b.id)
      affinity_seed = issue.affinity_seeds.first
      affinity_kind = AffinityKind.same_person

      expect(affinity_seed).to have_attributes({
        related_person_id: person_c.id,
        affinity_kind_id: affinity_kind.id
      })
    end

    it 'existing father with new children' do
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

      #     Action: Person_A has a new name Jona
      change_person_name(person_a, 'John', 'Doe')
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
      SamePersonAffinity::Finder.call(person_c)

      person_a.issues.last.approve!

      person_d = create_natural_person_with_docket('Jona', 'Brother')

      change_person_name(person_a, 'Jona', 'Brother')

      person_a.reload

      expect do
        SamePersonAffinity::Finder.call(person_a)
      end.to change{Issue.count}.by(1)

      issue = Issue.last
      expect(issue.person_id).to be(person_a.id)
      affinity_seed = issue.affinity_seeds.first
      affinity_kind = AffinityKind.same_person

      expect(affinity_seed).to have_attributes({
        related_person_id: person_d.id,
        affinity_kind_id: affinity_kind.id
      })
    end

    it 'exisiting children linked with existing relationship' do
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

      person_d.issues.last.approve!

      #   Action: Person_F has a new id ABC123
      change_person_identification(person_f, 'ABC123')

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
      end.to change{Issue.count}.by(1)

      issue = Issue.last
      expect(issue.person_id).to be(person_a.id)
      affinity_seed = issue.affinity_seeds.first
      affinity_kind = AffinityKind.same_person

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