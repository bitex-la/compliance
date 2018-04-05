require 'rails_helper'
require 'helpers/api/people_helper'

describe Person do
  Timecop.freeze Date.new(2018,01,01)
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
            notes: {data: []},
            affinities: {data: []}
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
          argentina_invoicing_details: {data: person.argentina_invoicing_details.map { |x| 
            {id: x.id.to_s, type: 'argentina_invoicing_details'}
          }},
          chile_invoicing_details: {data: person.chile_invoicing_details.map { |x| 
            {id: x.id.to_s, type: 'chile_invoicing_details'}
          }},
          phones: {data: person.phones.map { |x| 
            {id: x.id.to_s, type: 'phones'}
          }},
          emails: {data: person.emails.map { |x|
            {id: x.id.to_s, type: 'emails'}
          }},
          notes: {data: person.notes.map { |x|
            {id: x.id.to_s, type: 'notes'}
          }},
          affinities: {data: person.affinities.map { |x|
            {id: x.id.to_s, type: 'affinities'}
          }}
        }
      }

      related_person = person.affinities.first.related_person

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
            note_seeds: {data: issue.note_seeds.map { |x|
             {id: x.id.to_s, type: "note_seeds"}
            }},
            affinity_seeds: {data: issue.affinity_seeds.map { |x|
             {id: x.id.to_s, type: "affinity_seeds"}
            }},
            argentina_invoicing_detail_seed: {data: {
              id: issue.argentina_invoicing_detail_seed.id.to_s,
              type: "argentina_invoicing_detail_seeds"
            }},
            chile_invoicing_detail_seed: {data: nil},
            observations: {data: []}
          }
        },
        { type: "domiciles",
          id: person.domiciles.last.id.to_s,
          attributes: {
            country: "AR",
            state: "Buenos Aires",
            city: "C.A.B.A",
            street_address: "Cullen",
            street_number: "5229",
            postal_code: "1432",
            floor: "5",
            apartment: "A",
            created_at: "2018-01-01T00:00:00.000Z", 
            updated_at: "2018-01-01T00:00:00.000Z"
          },
          relationships: {
            person: {data: {id: person.id.to_s, type: "people"}},
            seed: {data: {
              type: "domicile_seeds",
              id: issue.domicile_seeds.first.id.to_s
            }},
            replaced_by: {data: nil},
            attachments: {
              data: person.domiciles.last.attachments
                .map{|x| {id: x.id.to_s, type: 'attachments'}}
            }
          }
        },
        { type: "identifications",
          id: person.identifications.last.id.to_s,
          attributes: {
            kind: "7",
            number: "2545566",
            issuer: "AR",
            public_registry_authority: nil,
            public_registry_book: nil,
            public_registry_extra_data: nil,
            created_at: "2018-01-01T00:00:00.000Z", 
            updated_at: "2018-01-01T00:00:00.000Z"
          },
          relationships: {
            person: {data: {id: person.id.to_s, type: "people"}},
            seed: {data: {
              type: "identification_seeds",
              id: issue.identification_seeds.last.id.to_s,
            }},
            replaced_by: {data: nil},
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
            nationality: "AR",
            gender: "1",
            marital_status: "1",
            job_title: 'Sr. Software developer',
            job_description: 'Build cool open source software',
            politically_exposed: false,
            politically_exposed_reason: nil,
            created_at: "2018-01-01T00:00:00.000Z", 
            updated_at: "2018-01-01T00:00:00.000Z"
          },
          relationships: {
            person: {data: {id: person.id.to_s, type: "people"}},
            seed: { data: {
	      type: "natural_docket_seeds",	    
              id: issue.natural_docket_seed.id.to_s
            }},
            replaced_by: {data: nil},
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
            kind: "USD",
            created_at: "2018-01-01T00:00:00.000Z", 
            updated_at: "2018-01-01T00:00:00.000Z"
          },
          relationships: {
            person: { data: {id: person.id.to_s, type:"people"}},
            seed: {data: {
              id: issue.allowance_seeds.first.id.to_s,
              type: "allowance_seeds"
            }},
            replaced_by: {data: nil},
            attachments: {
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
            kind: "USD",
            created_at: "2018-01-01T00:00:00.000Z", 
            updated_at: "2018-01-01T00:00:00.000Z"
          },
          relationships: {
            person: {data: {id: person.id.to_s, type:"people"}},
            seed: {data: {
              id: issue.allowance_seeds.last.id.to_s,
              type: "allowance_seeds"
            }},
            replaced_by: {data: nil},
            attachments: {
              data: person.allowances.last.attachments
                .map{|x| {id: x.id.to_s, type: 'attachments'}}
            }
          }
        },
        { type: "phones",
          id: person.phones.first.id.to_s,
          attributes: {
            number:  '+5491125410470',
            kind:    '1',
            country: 'AR',
            has_whatsapp: true,
            has_telegram: false,
            note: 'please do not call on Sundays',
            created_at: "2018-01-01T00:00:00.000Z", 
            updated_at: "2018-01-01T00:00:00.000Z"
          },
          relationships: {
            person: {data: {id: person.id.to_s, type: "people"}},
            seed: { data: {
	      type: "phone_seeds",	    
              id: issue.phone_seeds.last.id.to_s
            }},
            replaced_by: {data: nil},
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
            kind:    '1',
            created_at: "2018-01-01T00:00:00.000Z", 
            updated_at: "2018-01-01T00:00:00.000Z"         
          },
          relationships: {
            person: {data: {id: person.id.to_s, type: "people"}},
            seed: { data: {
	      type: "email_seeds",	    
              id: issue.email_seeds.last.id.to_s
            }},
            replaced_by: {data: nil},
            attachments: {
              data: person.emails.last.attachments
                .map{|x| {id: x.id.to_s, type: 'attachments'}}
            }
          }
        },
        { 
          type: "affinities",
          id: person.affinities.first.id.to_s,
          attributes: {
            kind: person.affinities.first.kind.to_s,
            created_at: "2018-01-01T00:00:00.000Z", 
            updated_at: "2018-01-01T00:00:00.000Z"         
          },
          relationships: {
            person: {data: {id: person.id.to_s, type: "people"}},
            seed: { data: {
	            type: "affinity_seeds",	    
              id: issue.affinity_seeds.last.id.to_s
            }},
            replaced_by: {data: nil},
            attachments: {
              data: person.affinities.last.attachments
                .map{|x| {id: x.id.to_s, type: 'attachments'}}
            },
            related_person: {
              data: {
                id: person.affinities.first.related_person.id.to_s, 
                type: "people"
              }
            }
          }
        },
        {
	  id: person.argentina_invoicing_details.first.id.to_s,    
          type: "argentina_invoicing_details",
          attributes: 
          {
            vat_status_id: "2",
            tax_id: "20955754290",
            tax_id_type: "80",
            receipt_type: "1",
            country: "AR",
            address: "Jujuy 3421",
            created_at: "2018-01-01T00:00:00.000Z", 
            updated_at: "2018-01-01T00:00:00.000Z"
          },
          relationships: 
          {
            person: {data: { id: person.id.to_s, type:"people"}},
            seed:   {data: { id: issue.argentina_invoicing_detail_seed.id.to_s,  type: "argentina_invoicing_detail_seeds"}},
            replaced_by: {data: nil},
            attachments: 
            {
              data: person.argentina_invoicing_details.last.attachments
                .map{|x| {id: x.id.to_s, type: 'attachments'}}
            }
          }
        },
        { type: "notes",
          id: person.notes.first.id.to_s,
          attributes: {
            title:  'my nickname',
            body:   'Please call me by my nickname: Mr. Bond',
            created_at: "2018-01-01T00:00:00.000Z", 
            updated_at: "2018-01-01T00:00:00.000Z"         
          },
          relationships: {
            person: {data: {id: person.id.to_s, type: "people"}},
            seed: { data: {
	      type: "note_seeds",	    
              id: issue.note_seeds.last.id.to_s
            }},
            replaced_by: {data: nil},
            attachments: {
              data: person.notes.last.attachments
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
