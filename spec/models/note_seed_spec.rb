require 'rails_helper'

RSpec.describe NoteSeed, type: :model do
  let(:invalid_note) { create(:full_note, body: nil) }

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
end

