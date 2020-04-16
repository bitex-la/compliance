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

  it_behaves_like 'seed_model',
    :notes,
    :full_note,
    :alt_full_note
end
