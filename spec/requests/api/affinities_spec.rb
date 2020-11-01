require "rails_helper"
require "helpers/shared_examples_for_api_endpoints"

describe Affinity do
  it_behaves_like 'jsonapi show and index',
    :affinities,
    :full_affinity_with_person,
    :alt_full_affinity_with_person,
    {affinity_kind_code_eq: 'spouse'},
    'related_person,person',
    'related_person,seed'

  it_behaves_like 'jsonapi show and index',
    :affinity_seeds,
    :full_affinity_seed_with_issue,
    :alt_full_affinity_seed_with_issue,
    {affinity_kind_code_eq: 'spouse'},
    'related_person,issue',
    'issue,related_person'

  it_behaves_like 'max people allowed request limit',
    :affinities,
    :full_affinity_with_person

  it_behaves_like 'max people allowed request limit',
    :affinity_seeds,
    :full_affinity_seed_with_person

  it_behaves_like 'seed', :affinities, :full_affinity, :alt_full_affinity, -> {
      {related_person: {
        data: {id: create(:empty_person).id.to_s, type: 'people'}
      }}
    }

  it_behaves_like 'has_many fruit', :affinities, :full_affinity, -> {
    {related_person: {
      data: {id: create(:empty_person).id.to_s, type: 'people'}
    }}
  }, {affinity_kind_code: 'stakeholder'}

  describe 'when adding a same_person affinity' do
    it 'works when same_person relation is not automatically detected' do
      issue = create(:basic_issue)

      initial_attrs = {
        affinity_kind_code: AffinityKind.same_person.code
      }

      initial_relations = {
        related_person: {
          data: {id: create(:empty_person).id.to_s, type: 'people'}
        }
      }
      issue_relation = { issue: { data: { id: issue.id.to_s, type: 'issues' } } }

      api_create "/affinity_seeds", {
        type: "affinity_seeds",
        attributes: initial_attrs,
        relationships: issue_relation.merge(initial_relations)
      }

      seed = api_response.data

      expect(seed.attributes.affinity_kind_code).to eq(initial_attrs[:affinity_kind_code].to_s)
    end

    it 'doesnt work when same_person relation already exists' do
      issue = create(:basic_issue)

      initial_attrs = {
        affinity_kind_code: AffinityKind.same_person.code
      }

      related_person = create(:empty_person)

      # create previous relation
      SamePersonAffinity::Fulfilment.build_same_person_affinity!(issue.person, related_person)

      initial_relations = {
        related_person: {
          data: {id: create(:empty_person).id.to_s, type: 'people'}
        }
      }
      issue_relation = { issue: { data: { id: issue.id.to_s, type: 'issues' } } }

      # expect a <422: Unprocessable Entity> response
      api_request(
        :post,
        "/affinity_seeds",
        {
          data: {
            type: "affinity_seeds",
            attributes: initial_attrs,
            relationships: issue_relation.merge(initial_relations)
          }
        },
        422)
    end
  end
end
