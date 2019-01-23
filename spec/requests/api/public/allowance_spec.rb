require "rails_helper"
require "helpers/shared_examples_for_api_endpoints"

describe Allowance do
  it_behaves_like 'public seed',
    :allowances,
    :salary_allowance,
    :alt_salary_allowance
end
