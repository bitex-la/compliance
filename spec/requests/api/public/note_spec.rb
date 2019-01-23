require "rails_helper"
require "helpers/shared_examples_for_api_endpoints"

describe Note do
  it_behaves_like 'public seed', :notes, :full_note, :alt_full_note
end
