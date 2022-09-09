require 'rails_helper'

describe AffinityGraphBuilder do
  let!(:argentina_tag) { create(:base_person_tag, tag_type: :person, name: 'active-in-AR') }
  let!(:chile_tag) { create(:base_person_tag, tag_type: :person, name: 'active-in-CL') }
  let!(:an_tag) { create(:base_person_tag, tag_type: :person, name: 'active-in-AN') }

  it 'returns relations for each affinity' do
    colombus_group = create(:full_legal_entity_person, tags: [an_tag, argentina_tag], country: 'CH', include_affinity: false)
                       .tap(&:reload)
                       .tap { |p| p.legal_entity_docket.update!(commercial_name: 'Grupo Colombus', legal_name: 'Grupo Colombus') }

    colombus_holding = create(:full_legal_entity_person, tags: [an_tag, argentina_tag], country: 'CH', include_affinity: false)
                       .tap(&:reload)
                       .tap { |p| p.legal_entity_docket.update!(commercial_name: 'Colombus Holding', legal_name: 'Colombus Holding') }

    the_h_group = create(:full_legal_entity_person, tags: [an_tag], country: 'CH', include_affinity: false)
                    .tap(&:reload)
                    .tap { |p| p.legal_entity_docket.update!(commercial_name: 'The H Group', legal_name: 'The H Group') }

    vinoscoop = create(:full_legal_entity_person, tags: [an_tag], country: 'CH', include_affinity: false)
                    .tap(&:reload)
                    .tap { |p| p.legal_entity_docket.update!(commercial_name: 'Vinoscoop', legal_name: 'Vinoscoop') }

    lara_h_group_owner = create(:full_natural_person, tags: [an_tag], country: 'CH', include_affinity: false)
                         .tap(&:reload)
                         .tap { |p| p.natural_docket.update!(first_name: 'Lara', last_name: 'Ermar') }

    colombus_group_manager = create(:full_natural_person, tags: [an_tag], country: 'AR', include_affinity: false)
                               .tap(&:reload)
                               .tap { |p| p.natural_docket.update!(first_name: 'Bernard', last_name: 'Ruiz') }

    lara_h_group_owner.affinities.create!(person: lara_h_group_owner,
                                         affinity_kind: AffinityKind.owner,
                                         related_person: the_h_group)

    colombus_holding.affinities.create!(person: colombus_holding,
                                        affinity_kind: AffinityKind.stakeholder,
                                        related_person: colombus_group)

    colombus_holding.affinities.create!(person: colombus_holding,
                                        affinity_kind: AffinityKind.payer,
                                        related_person: vinoscoop)

    colombus_holding.affinities.create!(person: colombus_holding,
                                        affinity_kind: AffinityKind.owner,
                                        related_person: the_h_group)

    colombus_group_manager.affinities.create!(person: colombus_group_manager,
                                    affinity_kind: AffinityKind.manager,
                                    related_person: colombus_group)

    first_affinity = colombus_group.all_affinities.first
    first_affinity_person = first_affinity.unscoped_related_one(colombus_group)
    first_affinity_edges = AffinityGraphBuilder.new
                                               .tap { |p| p.build_affinity_graph(colombus_group, first_affinity_person) }
                                               .edges

    expect(first_affinity_edges).to match_array([
                                            [colombus_group, colombus_holding],
                                            [colombus_holding, vinoscoop],
                                            [colombus_holding, the_h_group],
                                            [the_h_group, lara_h_group_owner]
                                          ])

    second_affinity = colombus_group.all_affinities.second
    second_affinity_person = second_affinity.unscoped_related_one(colombus_group)
    second_affinity_edges = AffinityGraphBuilder.new
                                                .tap { |p| p.build_affinity_graph(colombus_group, second_affinity_person) }
                                                .edges

    expect(second_affinity_edges).to match_array([
                                                   [colombus_group, colombus_group_manager]
                                                 ])

  end
end
