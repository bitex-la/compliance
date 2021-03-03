require "rails_helper"
require "helpers/shared_examples_for_api_endpoints"

describe LegalEntityDocket do
  it_behaves_like 'jsonapi show and index',
    :legal_entity_dockets,
    :full_legal_entity_docket_with_person,
    :alt_full_legal_entity_docket_with_person,
    {industry_eq: 'agriculture'},
    'industry,person',
    'person,seed'

  it_behaves_like 'jsonapi show and index',
    :legal_entity_docket_seeds,
    :full_legal_entity_docket_seed_with_issue,
    :alt_full_legal_entity_docket_seed_with_issue,
    {industry_eq: 'agriculture'},
    'industry,legal_name,issue',
    'person,attachments'

  it_behaves_like 'max people allowed request limit',
    :legal_entity_dockets,
    :full_legal_entity_docket_with_person

  it_behaves_like 'max people allowed request limit',
    :legal_entity_docket_seeds,
    :full_legal_entity_docket_seed_with_person

  it_behaves_like('seed', :legal_entity_dockets,
    :full_legal_entity_docket, :alt_full_legal_entity_docket)

  it_behaves_like('docket', :legal_entity_dockets, :full_legal_entity_docket)

  describe 'regulated_entity and operations_with_third_party_funds' do
    it 'creates successfully' do
      person = create(:empty_person).reload
      issue = create(:basic_issue, person: person)
      api_create '/legal_entity_docket_seeds',
                 type: 'legal_entity_docket_seeds',
                 attributes: attributes_for('full_legal_entity_docket_seed',
                                            copy_attachments: true),
                 relationships: {
                   issue: { data: { id: issue.id.to_s, type: 'issues' } }
                 }

      api_request :post, "/issues/#{issue.id}/approve"
      api_get "/legal_entity_dockets/#{LegalEntityDocket.last.id}"
      expect(api_response.data.attributes.to_h).to(
        include(regulated_entity: true,
                operations_with_third_party_funds: false)
      )
    end
  end
end
