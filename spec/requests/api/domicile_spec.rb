require "rails_helper"
require "helpers/shared_examples_for_api_endpoints"

describe Domicile do
  it_behaves_like 'jsonapi show and index',
    :domiciles,
    :full_domicile_with_person,
    :alt_full_domicile_with_person,
    {country_eq: 'VE'},
    'country,apartment,person',
    'person,seed'

  it_behaves_like 'jsonapi show and index',
    :domicile_seeds,
    :full_domicile_seed_with_issue,
    :alt_full_domicile_seed_with_issue,
    {country_eq: 'VE'},
    'country,apartment,issue',
    'issue,attachments'

  it_behaves_like 'max people allowed request limit',
    :domiciles,
    :full_domicile_with_person

  it_behaves_like 'max people allowed request limit',
    :domicile_seeds,
    :full_domicile_seed_with_person

  it_behaves_like('seed', :domiciles, :full_domicile, :alt_full_domicile)

  it_behaves_like('has_many fruit', :domiciles, :full_domicile)
end
