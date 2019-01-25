require "rails_helper"
require "helpers/shared_examples_for_api_endpoints"

describe Domicile do
  it_behaves_like 'public seed',
    :domiciles,
    :full_domicile,
    :alt_full_domicile
end
