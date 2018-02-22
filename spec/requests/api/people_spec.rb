require 'rails_helper'
require 'helpers/api/people_helper'

describe Person do
  describe 'getting a person' do
    it 'creates a new empty user and their initial issue' do
      Person.count.should == 0
      Issue.count.should == 0

      post '/api/people', params: { data: nil }

      Person.count.should == 1
      Issue.count.should == 1

      response.status.should == 201

      JSON.parse(response.body).deep_symbolize_keys.should == {
        data: {
          type: 'people',
          id: Person.last.id.to_s,
          relationships: {
            issues: {data: [{ type: 'issues', id: Issue.last.id.to_s }] },
            domiciles: {data: []},
            identifications: {data: []},
            natural_dockets: {data: []},
            legal_entity_dockets: {data: []},
            allowances: {data: []}
          }
        },
        included: [
          { type: 'issues',
            id: Issue.last.id.to_s,
            relationships: {
              person: {data: {id: Person.last.id.to_s, type: "people"}},
              domicile_seed: {data: nil},
              identification_seed: {data: nil},
              natural_docket_seed: {data: nil},
              legal_entity_docket_seed: {data: nil},
              relationship_seeds: {data: []},
              allowance_seeds: {data: []}
            }
          }
        ]
      }
    end

    it 'shows all the person info when the person exist' do
      person = create :full_natural_person
      get "/api/people/#{person.id}"
      assert_response 200
      JSON.parse(response.body).deep_symbolize_keys.should == {
        data: {
          type: 'people',
          id: person.id.to_s,
          relationships: {
            issues: {data: [{ type: 'issues', id: Issue.last.id.to_s }] },
            domiciles: {data: []},
            identifications: {data: []},
            natural_dockets: {data: []},
            legal_entity_dockets: {data: []},
            allowances: {data: []}
          }
        },
        included: [
          { type: 'issues',
            id: Issue.last.id.to_s,
            relationships: {
              person: {data: {id: person.id.to_s, type: "people"}},
              domicile_seed: {data: {id: DomicileSeed.first.id.to_s, type: "domicile_seeds"}},
              identification_seed: {data: {id: IdentificationSeed.first.id.to_s, type: "identification_seeds"}},
              natural_docket_seed: {data: {id: NaturalDocketSeed.first.id.to_s, type: "natural_docket_seeds"}},
              legal_entity_docket_seed: {data: nil},
              relationship_seeds: {data: []},
              allowance_seeds: {data: AllowanceSeed.where(issue: Issue.last).map{ |x| {id: x.id.to_s, type: "allowance_seeds" }}}
            }
          }
        ]
      }
    end

    it 'responds with a not found error 404 when the person does not exist' do
      get "/api/people/1"
      assert_response 404
    end

    it 'serializes to strict standard JSON' do
      pending
      fail
    end
  end
end
