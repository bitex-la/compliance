require "rails_helper"
require "helpers/shared_examples_for_api_endpoints"

describe Allowance do
  it_behaves_like 'jsonapi show and index',
    :allowances,
    :salary_allowance_with_person,
    :alt_salary_allowance_with_person,
    {kind_code_eq: 'vef'},
    'amount,kind_code,person',
    'person,seed'

  it_behaves_like 'jsonapi show and index',
    :allowance_seeds,
    :salary_allowance_seed_with_issue,
    :alt_salary_allowance_seed_with_issue,
    {kind_code_eq: 'vef'},
    'amount,kind_code,issue',
    'issue,attachments'

  it_behaves_like 'seed',
    :allowances,
    :salary_allowance,
    :alt_salary_allowance

  it_behaves_like 'has_many fruit',
    :allowances,
    :salary_allowance
end
