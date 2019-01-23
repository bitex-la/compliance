require "rails_helper"
require "helpers/shared_examples_for_api_endpoints"

describe Identification do
  it_behaves_like 'public seed',
    :identifications,
    :full_natural_person_identification,
    :alt_full_natural_person_identification
end
