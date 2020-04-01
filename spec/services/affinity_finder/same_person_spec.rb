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

    it 'creates a same_person AffinitySeed issue' do
        person.reload
        expect do
            AffinityFinder::SamePerson.call(person)
        end.to change { Issue.count }.by(1)
    end
  end