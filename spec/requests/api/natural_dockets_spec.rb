require "rails_helper"
require "helpers/shared_examples_for_api_endpoints"

describe NaturalDocket do
  it_behaves_like 'jsonapi show and index',
    :natural_dockets,
    :full_natural_docket_with_person,
    :alt_full_natural_docket_with_person,
    {first_name_eq: 'Joel'},
    'first_name,last_name,person',
    'person,seed'

  it_behaves_like 'jsonapi show and index',
    :natural_docket_seeds,
    :full_natural_docket_seed_with_issue,
    :alt_full_natural_docket_seed_with_issue,
    {first_name_eq: 'Joel'},
    'first_name,last_name,issue',
    'issue,attachments'

  it_behaves_like 'max people allowed request limit',
    :natural_dockets,
    :full_natural_docket_with_person

  it_behaves_like 'max people allowed request limit',
    :natural_docket_seeds,
    :full_natural_docket_seed_with_person

  it_behaves_like('seed', :natural_dockets,
    :full_natural_docket, :alt_full_natural_docket)

  it_behaves_like('docket', :natural_dockets, :full_natural_docket)

  it 'safe fail on invalid length' do
    issue = create(:basic_issue)

    initial_attrs = attributes_for("full_natural_docket_seed")
    initial_attrs["job_title"] = "0" * 256
    issue_relation = { issue: { data: { id: issue.id.to_s, type: 'issues' } } }

    api_create "/natural_docket_seeds", {
      type: "natural_docket_seeds",
      attributes: initial_attrs,
      relationships: issue_relation
    }, 422

    expect(api_response.errors.first.title).to eq('is too long (maximum is 255 characters)')
  end
end
