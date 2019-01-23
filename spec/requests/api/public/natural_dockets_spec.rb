require "rails_helper"
require "helpers/shared_examples_for_api_endpoints"

describe NaturalDocket do
  it_behaves_like 'public seed', :natural_dockets, :full_natural_docket,
    :alt_full_natural_docket
end
