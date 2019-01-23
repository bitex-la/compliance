require "rails_helper"
require "helpers/shared_examples_for_api_endpoints"

describe Email do
  it_behaves_like('public seed', :emails, :full_email, :alt_full_email)
end
