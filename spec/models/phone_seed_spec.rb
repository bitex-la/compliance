require 'rails_helper'

describe PhoneSeed do
  it { is_expected.to strip_attribute :number }
  it { is_expected.to strip_attribute :country }
  it { is_expected.to strip_attribute :note }

  it_behaves_like 'observable', :full_phone_seed_with_issue

  it_behaves_like 'archived_seed', :full_phone

  it_behaves_like 'whitespaced_seed', described_class.new, {
    number: ' +5491125410470 ',
    phone_kind_code: :main,
    country: 'AR ',
    note:  'please do not call on Sundays ',
  }

  it_behaves_like 'person_scopable',
    create: -> (person_id) {
      issue = create(:basic_issue, person_id: person_id)
      create(:full_phone_seed, issue: issue)
    }

  it_behaves_like 'model_validations', described_class

  it 'sets country to upper case' do
    seed = PhoneSeed.new(
      number: '+5491125410470',
      phone_kind_code: 'main',
      country: 'ar',
      has_whatsapp: true,
      has_telegram: false,
      note: 'please do not call on Sundays',
      issue: create(:basic_issue)
    )

    seed.save

    expect(seed.country).to eq('AR')
  end
end
