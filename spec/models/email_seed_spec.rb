require 'rails_helper'
require 'helpers/shared_examples_for_models'

RSpec.describe EmailSeed, type: :model do
  it { is_expected.to strip_attribute :address }

  it_behaves_like 'whitespaced_seed', described_class.new, {
    address: ' lazy@copypaste.com ',
    email_kind_code: 'invoicing'
  }
end
