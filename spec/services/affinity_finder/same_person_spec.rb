require 'rails_helper'

  describe AffinityFinder::SamePerson do
    let(:person) { create(:light_natural_person) }
    let(:valid_identification)   {
        create(:identification,
          person: person,
          identification_kind: IdentificationKind.find_by_code('national_id'),
          number: 'TheIDNumber',
          issuer: 'CO'
        )
    }

    context '.with_matched_id_numbers' do
      it 'matches exact numbers'
      it 'matches when person identification are contained in another record'
      it 'matches when another record number are contained in person identification'
      it 'returns empty array when no matches are found'
    end

    context '.with_matched_names' do
      it 'matches exact name and surname'
      it 'matches when person name are contained in another record'
      it 'matches when another record name are contained in person name'
      it 'returns empty array when no matches are found'
    end

    it 'creates a same_person AffinitySeed issue' do
        person.reload
        expect do
            AffinityFinder::SamePerson.call(person)
        end.to change { Issue.count }.by(1)
    end
  end