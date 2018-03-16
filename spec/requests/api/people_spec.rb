require 'rails_helper'
require 'helpers/api/people_helper'

describe Person do
  describe 'getting a person' do
    it 'creates a new empty user and their initial issue' do
      expect do
        post '/api/people', params: { data: nil }
      end.to change{ Person.count }.by(1)

      response.status.should == 201
      json_response.should == {
        data: {
          type: 'people',
          id: Person.last.id.to_s,
          attributes: {
            enabled: false,
            risk: nil
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
            phones: {data: []},
            emails: {data: []},
            relationships: {data: []}
          }
        },
        included: []
      }
    end

    it 'shows all the person info when the person exist' do
      person = create :full_natural_person
      issue = person.issues.first

      get "/api/people/#{person.id}"
      assert_response 200
      json_response = JSON.parse(response.body).deep_symbolize_keys

      
      json_response[:data].should == {
        type: 'people',
        id: person.id.to_s,
        attributes: {
          enabled: true,
          risk: 'medium',
        },
        relationships: {
          issues: {data: [{ type: 'issues', id: issue.id.to_s }] },
          domiciles: {data: [{
            id: person.domiciles.last.id.to_s,
            type: "domiciles"
          }]},
          identifications: {data: [{
            id: person.identifications.last.id.to_s,
            type: "identifications"
          }]},
          natural_dockets: {data: [{
            id: person.natural_dockets.last.id.to_s,
            type: "natural_dockets"
          }]},
          legal_entity_dockets: {data: []},
          allowances: {data: person.allowances.map{ |x|
            {id: x.id.to_s, type: "allowances" }
          }},
          argentina_invoicing_details: {data: []},
          chile_invoicing_details: {data: []},
          phones: {data: person.phones.map { |x| 
            {id: x.id.to_s, type: 'phones'}
          }},
          emails: {data: person.emails.map { |x|
            {id: x.id.to_s, type: 'emails'}
          }},
          relationships: {data: person.relationships.map { |x|
            {id: x.id.to_s, type: 'relationships'}
          }}
        }
      }

      related_person = person.relationships.first.related_person

      expected_included = [
        { type: 'issues',
          id: issue.id.to_s,
          attributes: {
            state: 'approved',
          },
          relationships: {
            person: {data: {id: person.id.to_s, type: "people"}},
            domicile_seeds: { data: [{
              id: issue.domicile_seeds.first.id.to_s,
              type: "domicile_seeds"
            }]},
            identification_seeds: { data: [{
              id: issue.identification_seeds.first.id.to_s,
              type: "identification_seeds"
            }]},
            natural_docket_seed: {data: {
              id: issue.natural_docket_seed.id.to_s,
              type: "natural_docket_seeds"
            }},
            legal_entity_docket_seed: {data: nil},
            allowance_seeds: {data: issue.allowance_seeds.map{ |x|
              {id: x.id.to_s, type: "allowance_seeds" }
            }},
            phone_seeds: {data: issue.phone_seeds.map { |x|
             {id: x.id.to_s, type: "phone_seeds"}
            }},
            email_seeds: {data: issue.email_seeds.map { |x|
             {id: x.id.to_s, type: "email_seeds"}
            }},
            relationship_seeds: {data: issue.relationship_seeds.map { |x|
             {id: x.id.to_s, type: "relationship_seeds"}
            }},
            argentina_invoicing_detail_seed: {data: nil},
            chile_invoicing_detail_seed: {data: nil},
            observations: {data: []}
          }
        },
        { type: "domiciles",
          id: person.domiciles.last.id.to_s,
          attributes: {
            country: "Argentina",
            state: "Buenos Aires",
            city: "C.A.B.A",
            street_address: "Cullen",
            street_number: "5229",
            postal_code: "1432",
            floor: "5",
            apartment: "A"
          },
          relationships: {
            person: {data: {id: person.id.to_s, type: "people"}},
            seed: {data: {
              type: "domicile_seeds",
              id: issue.domicile_seeds.first.id.to_s
            }},
            attachments: {
              data: person.domiciles.last.attachments
                .map{|x| {id: x.id.to_s, type: 'attachments'}}
            }
          }
        },
        { type: "identifications",
          id: person.identifications.last.id.to_s,
          attributes: {
            kind: "ID",
            number: "2545566",
            issuer: "Argentina",
            public_registry_authority: nil,
            public_registry_book: nil,
            public_registry_extra_data: nil
          },
          relationships: {
            person: {data: {id: person.id.to_s, type: "people"}},
            seed: {data: {
              type: "identification_seeds",
              id: issue.identification_seeds.last.id.to_s,
            }},
            attachments: {
              data: person.identifications.last.attachments
                .map{|x| {id: x.id.to_s, type: 'attachments'}}
            }
          }
        },
        { type: "natural_dockets",
          id: person.natural_dockets.first.id.to_s,
          attributes: {
            first_name: "Joe",
            last_name: "Doe",
            birth_date: "2018-02-26",
            nationality: "Argentina",
            gender: "Male",
            marital_status: "Single",
            job_title: 'Sr. Software developer',
            job_description: 'Build cool open source software',
            politically_exposed: false,
            politically_exposed_reason: nil
          },
          relationships: {
            person: {data: {id: person.id.to_s, type: "people"}},
            seed: { data: {
	      type: "natural_docket_seeds",	    
              id: issue.natural_docket_seed.id.to_s
            }},
            attachments: {
              data: person.natural_dockets.last.attachments
                .map{|x| {id: x.id.to_s, type: 'attachments'}}
            }
          }
        },
        { type: "allowances",
          id: person.allowances.first.id.to_s,
          attributes: {
            weight: 1000,
            amount: 1000,
            kind:"USD"
          },
          relationships: {
            person: { data: {id: person.id.to_s, type:"people"}},
            seed: {data: {
              id: issue.allowance_seeds.first.id.to_s,
              type: "allowance_seeds"
            }},
            attachments:{
              data: person.allowances.first.attachments
                .map{|x| {id: x.id.to_s, type: 'attachments'}}
            }
          }
        },
        { type: "allowances",
          id: person.allowances.last.id.to_s,
          attributes: {
            weight: 1000,
            amount: 1000,
            kind: "USD"
          },
          relationships: {
            person: {data: {id: person.id.to_s, type:"people"}},
            seed: {data: {
              id: issue.allowance_seeds.last.id.to_s,
              type: "allowance_seeds"
            }},
            attachments:{
              data: person.allowances.last.attachments
                .map{|x| {id: x.id.to_s, type: 'attachments'}}
            }
          }
        },
        { type: "phones",
          id: person.phones.first.id.to_s,
          attributes: {
            number:  '+5491125410470',
            kind:    'cellphone',
            country: 'Argentina',
            has_whatsapp: true,
            has_telegram: false,
            note: 'please do not call on Sundays'
          },
          relationships: {
            person: {data: {id: person.id.to_s, type: "people"}},
            seed: { data: {
	      type: "phone_seeds",	    
              id: issue.phone_seeds.last.id.to_s
            }},
            attachments: {
              data: person.phones.last.attachments
                .map{|x| {id: x.id.to_s, type: 'attachments'}}
            }
          }
        },
        { type: "emails",
          id: person.emails.first.id.to_s,
          attributes: {
            address:  'joe.doe@test.com',
            kind:    'personal'          
          },
          relationships: {
            person: {data: {id: person.id.to_s, type: "people"}},
            seed: { data: {
	      type: "email_seeds",	    
              id: issue.email_seeds.last.id.to_s
            }},
            attachments: {
              data: person.emails.last.attachments
                .map{|x| {id: x.id.to_s, type: 'attachments'}}
            }
          }
        },
        { type: "relationships",
          id: person.relationships.first.id.to_s,
          attributes: {
            kind: person.relationships.first.kind.to_s          
          },
          relationships: {
            person: {data: {id: person.id.to_s, type: "people"}},
            seed: { data: {
	      type: "relationship_seeds",	    
              id: issue.relationship_seeds.last.id.to_s
            }},
            attachments: {
              data: person.relationships.last.attachments
                .map{|x| {id: x.id.to_s, type: 'attachments'}}
            }
          }
        }
      ]

      json_response[:included].each_with_index do |got, i|
        got.should == expected_included[i]
      end
    end

    it 'responds 404 when the person does not exist' do
      get "/api/people/1"
      assert_response 404
    end

    it 'serializes to strict standard JSON' do
      pending
      fail
    end
  end
end
