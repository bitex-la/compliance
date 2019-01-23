require "rails_helper"
require "helpers/shared_examples_for_api_endpoints"

describe Phone do
  it_behaves_like('public seed', :phones, :full_phone, :alt_full_phone)
end
