require 'rails_helper'

RSpec.describe Email, type: :model do
  it_behaves_like 'archived_fruit', :emails, :full_email

  it_behaves_like 'fruit_scopeable', :emails, :full_email
end
