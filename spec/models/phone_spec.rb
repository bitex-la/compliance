require 'rails_helper'

describe Phone do
  it_behaves_like 'archived_fruit', :phones, :full_phone

  it_behaves_like 'person_scopable_fruit', :full_phone
end
