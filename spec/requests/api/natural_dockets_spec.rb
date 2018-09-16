require "rails_helper"
require "helpers/shared_examples_for_api_endpoints"

describe NaturalDocket do
  it_behaves_like 'jsonapi show and index',
    :natural_dockets,
    :full_natural_docket_with_person, :alt_full_natural_docket_with_person,
    {first_name_eq: 'Joel'},
    'first_name,last_name,person',
    'person,seed'

  it_behaves_like 'jsonapi show and index',
    :natural_docket_seeds,
    :full_natural_docket_seed_with_issue, :alt_full_natural_docket_seed_with_issue,
    {first_name_eq: 'Joel'},
    'first_name,last_name,issue',
    'issue,attachments'

  it_behaves_like('seed', :natural_dockets,
    :full_natural_docket, :alt_full_natural_docket)

  it_behaves_like('docket', :natural_dockets, :full_natural_docket)
end
