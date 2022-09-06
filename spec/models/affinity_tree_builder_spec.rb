require 'rails_helper'

describe AffinityTreeBuilder do
  let!(:argentina_tag) { create(:base_person_tag, tag_type: :person, name: 'active-in-AR') }
  let!(:chile_tag) { create(:base_person_tag, tag_type: :person, name: 'active-in-CL') }

  it 'builds proper affinity tree' do
    argentina_person = create(:full_natural_person, tags: [argentina_tag], country: 'AR', include_affinity: false)
                         .tap(&:reload)
                         .tap { |p| p.natural_docket.update!(first_name: 'Ricardo', last_name: 'Molina') }
    chile_person = create(:full_natural_person, tags: [chile_tag], country: 'CL', include_affinity: false)
                     .tap(&:reload)
                     .tap { |p| p.natural_docket.update!(first_name: 'Pablito', last_name: 'Ruiz') }
    chile_legal_entity = create(:full_legal_entity_person, tags: [chile_tag], country: 'CL', include_affinity: false)
                           .tap(&:reload)
                           .tap { |p| p.legal_entity_docket.update!(legal_name: 'E Corp') }

    argentina_person.affinities.create!(person: argentina_person,
                                        affinity_kind: AffinityKind.payer,
                                        related_person: chile_legal_entity)

    chile_person.affinities.create!(person: chile_person,
                                    affinity_kind: AffinityKind.stakeholder,
                                    related_person: chile_legal_entity)

    argentina_person.all_affinities.each do |affinity|
      affinity_person = affinity.unscoped_related_one(argentina_person)
      pp "#{argentina_person.name}"
      pp AffinityTreeBuilder.new.tap { |p| p.build_affinity_graph(argentina_person, affinity_person) }.edges
    end
  end
end
