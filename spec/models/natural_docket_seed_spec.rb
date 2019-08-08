require 'rails_helper'

describe NaturalDocketSeed do
  let(:invalid_seed) { described_class.new }
  let(:valid_seed)   { 
    create(:natural_docket_seed, 
      issue: create(:basic_issue),
      nationality: 'CO',
      gender: GenderKind.find_by_code('female'),
      marital_status: MaritalStatusKind.find_by_code('single')
  )}

  it_behaves_like 'observable', :full_natural_docket_seed_with_issue

  %i(first_name last_name nationality
    job_title job_description
  ).each do |attr|
    it { is_expected.to strip_attribute attr }
  end

  it_behaves_like 'whitespaced_seed', described_class.new, {
    first_name: ' Mr Joe ',
    last_name: '  Whitspace  ', 
    nationality: 'AR ',
    job_title: ' Developer ',
    job_description: '  I use a lot of spaces '
  }

  it 'is not valid without an issue' do
    expect(invalid_seed).to_not be_valid
  end

  it 'is valid with an issue' do
    expect(valid_seed).to be_valid
  end

  it 'trims special characters at the beginning of a birthdate' do
    seed = described_class.new(
      first_name: 'Mr Joe',
      last_name:  'Black', 
      nationality: 'AR',
      job_title: ' Developer',
      job_description: 'code for food',
      issue: create(:basic_issue)
    )
    seed.update_attributes!(birth_date: '-1985-10-08-')
    expect(seed.birth_date.strftime("%Y-%m-%d")).to eq '1985-10-08'
    seed.update_attributes!(birth_date: '-1985/10/08-')
    expect(seed.birth_date.strftime("%Y-%m-%d")).to eq '1985-10-08'
  end

  it 'does not allow assigning to an issue that already has one' do
    seed = create(:full_natural_docket_seed_with_issue).reload

    invalid = build(:full_natural_docket_seed, issue: seed.issue.reload)
    invalid.should_not be_valid
    invalid.errors[:base].should == ["cannot_create_more_than_one_per_issue"]
  end

  it 'cannot save if issue is not active anymore' do
    seed = create(:full_natural_docket_seed_with_issue).reload
    seed.issue.approve!
    seed.first_name = "An update here"
    seed.should_not be_valid
    seed.errors[:base].should == ['no_more_updates_allowed']
  end

  it 'create a natural docket with long accented text in job_description' do
    person = create(:empty_person)
    issue = Issue.new(person: person)
    create(:strange_natural_docket_seed, issue: issue)
  end
end
