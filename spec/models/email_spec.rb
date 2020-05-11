require 'rails_helper'

RSpec.describe Email, type: :model do
  it_behaves_like 'archived_fruit', :emails, :full_email

  it_behaves_like 'person_scopable_fruit', :full_email
end
