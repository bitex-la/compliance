require 'rails_helper'

describe Affinity do
  it_behaves_like 'archived_fruit', :affinities, :full_affinity

  it 'has a custom name_body' do
    person = create(:basic_issue).reload.person
    create(:full_affinity, person: person)
      .name.should =~ /Affinity#[0-9]*?: business_partner/
  end

  it 'validates that affinity kind cannot be repeated between two people' do
    person = create(:basic_issue).reload.person
      create(:full_affinity, person: person)

    related_person = person.affinities.first.related_person

    repeated_one = described_class.new(
      person: person,
      related_person: related_person,
      affinity_kind_code: :business_partner
    )

    expect(repeated_one).to_not be_valid
    expect(repeated_one.errors[:base]).to eq ['affinity_already_exists']
  end

  it 'allows to have more than one relationship between two persons with a different kind' do
    person = create(:basic_issue).reload.person
      create(:full_affinity, person: person)

    related_person = person.affinities.first.related_person

    couple_affinity = described_class.new(
      person: person,
      related_person: related_person,
      affinity_kind_code: :couple
    )

    expect(couple_affinity).to be_valid
    couple_affinity.save

    repeated_one = described_class.new(
      person: person,
      related_person: related_person,
      affinity_kind_code: :couple
    )

    expect(repeated_one).to_not be_valid
    expect(repeated_one.errors[:base]).to eq ['affinity_already_exists']
  end

  it 'validate that cannot link to itself' do
    person = create(:empty_person)
    related_person = create(:empty_person)
    fruit = described_class.new(
      person: person,
      related_person: person,
      affinity_kind_code: :business_partner
    )

    expect(fruit.save).to be false
    expect(fruit.errors[:base]).to eq ['cannot_link_to_itself']
  end

  describe 'when calculate inverse of relationships' do
    it 'returns the inverse kind of a person that is the related on' do
      person = create(:basic_issue).reload.person
      create(:full_affinity, person: person)

      related_person = person.affinities.first.related_person
      affinity = related_person.all_affinities.first
      expect(
        affinity.affinity_kind.inverse
      ).to eq :business_partner_of
    end

    %i(spouse business_partner couple manager immediate_family
      extended_family other partner same_person
    ).each do |kind|
      it "get symmetrical affinity for #{kind} with _of suffix" do
        person = create(:basic_issue).reload.person
        create(:full_affinity, person: person, affinity_kind_code: kind)

        related_person = person.affinities.first.related_person
        affinity = related_person.all_affinities.first
        expect(
          affinity.affinity_kind.inverse
        ).to eq "#{kind}_of".to_sym
      end
    end

    %i(payee owner customer stakeholder payer provider).each do |kind|
      it "get non-symmetrical affinity of #{kind}" do
        person = create(:basic_issue).reload.person
        create(:full_affinity, person: person, affinity_kind_code: kind)

        affinity = person.all_affinities.first
        expect(
          affinity.affinity_kind.inverse
        ).to eq AffinityKind.send(kind).inverse
      end
    end
  end
end
