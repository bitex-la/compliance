require "rails_helper"
require "helpers/shared_examples_for_api_endpoints"

describe LegalEntityDocket do
  it_behaves_like('public seed', :legal_entity_dockets,
    :full_legal_entity_docket, :alt_full_legal_entity_docket)
end
