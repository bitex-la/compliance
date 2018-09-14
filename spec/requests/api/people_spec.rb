require 'rails_helper'
require 'helpers/api/people_helper'

describe Person do
  Timecop.freeze Date.new(2018,01,01)
  let(:admin_user) { create(:admin_user) }

  describe 'getting a person' do
    it 'creates a new empty user and their initial issue' do
      expect{ api_create('/people', nil) }.to change{ Person.count }.by(1)

      json_response.should == {
        data: {
          type: 'people',
          id: Person.last.id.to_s,
          attributes: {
            enabled: false,
            risk: nil,
            created_at: 1514764800,
            updated_at: 1514764800
          },
          relationships: {
            issues: {data: []},
            domiciles: {data: []},
            identifications: {data: []},
            natural_dockets: {data: []},
            legal_entity_dockets: {data: []},
            argentina_invoicing_details: {data: []},
            chile_invoicing_details: {data: []},
            allowances: {data: []},
            fund_deposits: {data: []},
            phones: {data: []},
            emails: {data: []},
            notes: {data: []},
            affinities: {data: []},
            risk_scores: {data: []},
            attachments: {data: []},
          }
        },
        included: []
      }
    end

    it 'shows all the person info when the person exist' do
      person = create(:full_natural_person).reload
      issue = person.issues.first

      # This is an old domiciel, that should not be included in the response.
      create(:full_domicile, person: person, replaced_by: person.domiciles.last)

      api_get "/people/#{person.id}"
      json_response = JSON.parse(response.body).deep_symbolize_keys
      person.reload

      json_response[:data].should == {
        type: 'people',
        id: person.id.to_s,
        attributes: {
          enabled: true,
          risk: 'medium',
          created_at: 1514764800,
          updated_at: 1514764800
        }
      }
    end

    it 'can update a person attributes' do
      person = create(:empty_person)

      api_update "/people/#{person.id}", {
        type: "people",
        id: person.id,
        attributes: { enabled: true }
      }

      person.reload.should be_enabled
    end

    it 'responds 404 when the person does not exist' do
      api_get "/people/1", {}, 404
    end
  end

  describe 'when using filters' do
    it 'filters by name' do
      joe_doe = create :full_natural_person
      pending_joe_doe = create :new_natural_person
      empty = create :empty_person
      bob_doe = create(:new_natural_person).reload  
      bob_doe.issues.last.natural_docket_seed.update(first_name: 'bob')
      bob_doe.issues.last.approve!
      bob_doe.reload.natural_docket.first_name.should == 'bob'

      api_get "/people"
      api_response.data.count.should == Person.count

      # URL encoded json with ransack filters.

      api_get "/people/?filter[natural_dockets_first_name_or_natural_dockets_last_name_cont]=joe"
      api_response.data.count.should == 1

      api_get "/people/?filter[identifications_number_or_argentina_invoicing_details_tax_id_eq]=20955754290"
      api_response.data.count.should == 2 # joe & bob

      api_get "/people/?filter[natural_dockets_first_name_or_natural_dockets_last_name_cont]=doe"
      api_response.data.count.should == 2 # joe & bob
    end
  end
end
