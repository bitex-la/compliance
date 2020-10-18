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

  # TODO: add validation specs for same_person (seba)
end
