require 'rails_helper'
require "helpers/shared_examples_for_models"

RSpec.describe PhoneSeed, type: :model do
  it { is_expected.to strip_attribute :number }
  it { is_expected.to strip_attribute :country }
  it { is_expected.to strip_attribute :note }

  expect(whitespaced_seed.number).to eq '+5491125410470'
  expect(whitespaced_seed.note).to eq 'please do not call on Sundays'
  expect(whitespaced_seed.country).to eq 'AR'

  it_behaves_like 'whitespaced_seed', described_class.new, {
    number: ' +5491125410470 ',
    phone_kind_code: 'main',
    country: 'AR ',
    note:  'please do not call on Sundays ',
  }
end
