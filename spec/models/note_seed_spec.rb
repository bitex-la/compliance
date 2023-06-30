require 'rails_helper'
require "helpers/shared_examples_for_models"

RSpec.describe NoteSeed, type: :model do
  let(:invalid_note) { create(:full_note, body: nil) }

  it_behaves_like 'archived_seed', :full_note

  it { is_expected.to strip_attribute :title }
  it { is_expected.to strip_attribute :body }

  it 'create a note seed with long accented text' do
    person = create(:empty_person)
    issue = Issue.new(person: person)
    create(:strange_note_seed, issue: issue)
  end

  it 'is not valid without body' do
    person = create(:empty_person)
    issue = Issue.new(person: person)  
    expect(described_class.new(issue: issue, body: nil)).to_not be_valid
  end

  it_behaves_like 'whitespaced_seed', described_class.new, {
    title: '  A long spaced title   ',
    body: '  The body  ',
  }

  it_behaves_like 'person_scopable',
    create: -> (person_id) {
      issue = create(:basic_issue, person_id: person_id)
      create(:full_note_seed, issue: issue)
    }

  it_behaves_like 'model_validations', described_class

  it 'filter issue note_seeds when user admin is auditor' do
    admin_user = create(:admin_user)
    AdminUser.current_admin_user = admin_user 
    Settings.fiat_only['start_date'] = (Date.today - 1).strftime('%Y%m%d')
    Settings.fiat_only['audit_emails'] = [ admin_user.email ]

    new_issue = create(:basic_issue)
    create(:full_note_seed, issue: new_issue)
    create(:full_note_seed, issue: new_issue)
    create(:full_note_seed, issue: new_issue)

    new_issue.note_seeds.reload
    expect(new_issue.note_seeds.count).to eq 3

    Settings.fiat_only['start_date'] = (Date.today + 1).strftime('%Y%m%d')
    new_issue.note_seeds.reload
    expect(new_issue.note_seeds.count).to eq 0
  end
end
