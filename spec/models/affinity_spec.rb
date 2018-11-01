require 'rails_helper'

describe Affinity do
  it 'has a custom name_body' do
    person = create(:basic_issue).reload.person
    create(:full_affinity, person: person)
      .name.should =~ /Affinity#[0-9]*?: business_partner/
  end

  describe 'when calculate inverse of relationships' do
    it 'returns the inverse kind of a person that is the related on' do 
      person = create(:basic_issue).reload.person
      create(:full_affinity, person: person)

      related_person = person.affinities.first.related_person
      affinity = related_person.inbound_affinities.first
      expect(
        affinity.affinity_kind.inverse_of
      ).to eq :business_partner
    end

    it 'get inverse affinity of payee' do
      person = create(:basic_issue).reload.person
      create(:full_affinity, person: person, affinity_kind_code: :payee)

      affinity = person.outbound_affinities.first
      expect(
        affinity.affinity_kind.inverse_of
      ).to eq :payer
    end
  end
end
