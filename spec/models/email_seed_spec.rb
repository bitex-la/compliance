require 'rails_helper'
require 'helpers/shared_examples_for_models'

RSpec.describe EmailSeed, type: :model do
  it { is_expected.to strip_attribute :address }

  it_behaves_like 'whitespaced_seed', described_class.new, {
    address: ' lazy@copypaste.com ',
    email_kind_code: :invoicing
  }

  it_behaves_like 'observable', :full_email_seed_with_issue

  it_behaves_like 'person_scopable',
    create: -> (person_id) {
      issue = create(:basic_issue, person_id: person_id)
      create(:full_email_seed, issue: issue)
    }

  it_behaves_like 'archived_seed', :full_email

  it_behaves_like 'model_validations', described_class
end
