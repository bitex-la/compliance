require 'rails_helper'

RSpec.describe Note, type: :model do
  let(:person) { create(:empty_person) }

  it_behaves_like 'archived_fruit', :notes, :full_note

  it_behaves_like 'fruit_scopeable',
    :notes,
    :full_note

  it 'is not valid without body' do
    expect(described_class.new(person: person, body: nil))
      .to_not be_valid
  end
end
