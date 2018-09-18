require 'rails_helper'

RSpec.describe NoteSeed, type: :model do
  it 'create a note seed with long accented text' do
    person = create(:empty_person)
    issue = Issue.new(person: person)
    long_seed = create(:strange_note_seed, issue: issue)
  end
end

