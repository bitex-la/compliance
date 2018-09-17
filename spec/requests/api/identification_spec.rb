require "rails_helper"
require "helpers/shared_examples_for_api_endpoints"

describe Identification do
  it_behaves_like 'jsonapi show and index',
    :identifications,
    :full_natural_person_identification_with_person,
    :alt_full_natural_person_identification_with_person,
    {identification_kind_code_eq: 'passport'},
    'number,identification_kind_code,person',
    'person,seed'

  it_behaves_like 'jsonapi show and index',
    :identification_seeds,
    :full_natural_person_identification_seed_with_issue,
    :alt_full_natural_person_identification_seed_with_issue,
    {identification_kind_code_eq: 'passport'},
    'number,identification_kind_code,issue',
    'issue,attachments'

  it_behaves_like 'seed',
    :identifications,
    :full_natural_person_identification,
    :alt_full_natural_person_identification

  it_behaves_like 'has_many fruit',
    :identifications,
    :full_natural_person_identification
end
