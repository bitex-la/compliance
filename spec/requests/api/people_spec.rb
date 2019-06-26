require 'rails_helper'

describe Person do
  let(:admin_user) { create(:admin_user) }
  before :each do 
    Timecop.freeze Date.new(2018,01,01)
  end

  before :each do
    Timecop.freeze Date.new(2018,01,01)
  end

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
            updated_at: 1514764800,
            person_type: nil
          },
          relationships: {
            regularity: { data: {
              id: '1', 
              type: 'regularities'
            }},
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
            tags: {data: []}
          }
        },
        included: [{ 
          id: '1',
          type: 'regularities', 
          attributes: { 
            code: 'none', 
            funding_amount: 0, 
            funding_count:0 
          }
        }]
      }
    end

    it 'shows all the person info when the person exist' do
      person = create(:full_natural_person,:with_tags).reload
      issue = person.issues.first

      # This is an old domicile, that should not be included in the response.
      create(:full_domicile, person: person, replaced_by: person.domiciles.last)

      api_get "/people/#{person.id}"
      person.reload

      json_response[:data].should == {
        type: 'people',
        id: person.id.to_s,
        attributes: {
          enabled: true,
          risk: 'medium',
          created_at: 1514764800,
          updated_at: 1514764800,
          person_type: "natural_person"
        },
        relationships: {
          regularity: { data: {
              id: '1', 
              type: 'regularities'
          }},
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
          fund_deposits: {data: person.fund_deposits.map{ |x|
            {id: x.id.to_s, type: "fund_deposits" }
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
          }},
          risk_scores: {data: person.risk_scores.map{ |x|
            {id: x.id.to_s, type: "risk_scores" }
          }},
          attachments: {data: issue.person.attachments.map { |x|
            {id: x.id.to_s, type: "attachments"}
          }},
          tags: {data: issue.person.tags.map { |x|
            {id: x.id.to_s, type: "tags"}
          }},
        }
      }

      related_person = person.affinities.first.related_person
      expected_included = [
        { type: 'issues',
          id: issue.id.to_s,
          attributes: {
            state: 'approved',
            created_at: 1514764800,
            updated_at: 1514764800
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
            created_at: 1514764800,
            updated_at: 1514764800
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
            identification_kind_code: "national_id",
            number: "2545566",
            issuer: "AR",
            public_registry_authority: nil,
            public_registry_book: nil,
            public_registry_extra_data: nil,
            created_at: 1514764800,
            updated_at: 1514764800
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
        { id: person.natural_dockets.first.id.to_s,
          type: "natural_dockets",
          attributes: {
            first_name: "Joe",
            last_name: "Doe",
            nationality: "AR",
            gender_code: "male",
            marital_status_code: "single",
            job_title: 'Sr. Software developer',
            job_description: 'Build cool open source software',
            politically_exposed: false,
            politically_exposed_reason: nil,
            birth_date: person.natural_dockets.first.birth_date.to_formatted_s,
            created_at: 1514764800,
            updated_at: 1514764800
          },
          relationships: {
            person: {data: {id: person.id.to_s, type: "people"}},
            replaced_by: {data: nil},
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
            kind: "USD",
            created_at: 1514764800,
            updated_at: 1514764800
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
            kind_code: "usd",
            created_at: 1514764800,
            updated_at: 1514764800
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
            phone_kind_code: 'main',
            country: 'AR',
            has_whatsapp: true,
            has_telegram: false,
            note: 'please do not call on Sundays',
            created_at: 1514764800,
            updated_at: 1514764800
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
            address:  person.emails.first.address,
            email_kind_code: 'authentication',
            created_at: 1514764800,
            updated_at: 1514764800
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
            affinity_kind_code: person.affinities.first.affinity_kind.to_s,
            created_at: 1514764800,
            updated_at: 1514764800
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
            vat_status_code: "monotributo",
            tax_id: "20955754290",
            tax_id_kind_code: "cuit",
            receipt_kind_code: "a",
            country: "AR",
            full_name: "Julio Iglesias",
            address: "Jujuy 3421",
            created_at: 1514764800,
            updated_at: 1514764800
          },
          relationships:
          {
            person: {data: { id: person.id.to_s, type:"people"}},
            seed:   {data: {
              id: issue.argentina_invoicing_detail_seed.id.to_s,
              type: "argentina_invoicing_detail_seeds"}},
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
            created_at: 1514764800,
            updated_at: 1514764800
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

      %w(
        argentina_invoicing_details
        affinities
        notes
        emails
        phones
        natural_dockets
        identifications
        domiciles
      ).each do |fruit|
        json_response[:included].find{|x| x[:type] == fruit}[:attributes]
          .should == expected_included.find{|x| x[:type] == fruit}[:attributes]
      end
    end

    it 'can fetch simple person with attributes only' do
      person = create(:full_natural_person).reload
      api_get "/people/#{person.id}/?fields[people]=enabled"
      json_response.should == {
        data: {
          type: 'people',
          id: person.id.to_s,
          relationships: {},
          attributes: { enabled: true }
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


    it 'create new person with tags' do
      person_tag = create(:person_tag)

      expect do
        api_create('/people', {
          type: 'people',
          attributes: { enabled: true, risk:"low" },
          relationships: { 
            tags: {data: [{id: person_tag.id, type: 'tags'}] }
          }
        })
      end.to change{Person.count}.by(1)

      person = Person.find(api_response.data.id)
      expect(person.tags).to include person_tag
      expect(person.enabled).to eq true
      expect(person.risk).to eq "low"
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
      api_response.data.count.should == 5

      api_get "/people/?filter[identifications_number_or_argentina_invoicing_details_tax_id_eq]=20955754290"
      api_response.data.count.should == 2 # joe & bob

      api_get "/people/?filter[natural_dockets_first_name_or_natural_dockets_last_name_cont]=doe"
      api_response.data.count.should == 6 # joe & bob
    end
  end

  describe 'when caching' do
    it 'caches the person but does not clash if fields or includes differ' do
      # Caching in tests is cumbersome, so there's all this boilerplate and
      # we need to redefine the caching action.
      # Focus on testing our cache path generation and regex based sweeping.
      Rails.application.config.cache_store = :file_store
      Api::PeopleController.caches_action :show, expires_in: 2.minutes,
        cache_path: :path_for_show

      person = create(:full_natural_person).reload

      # These requests will cache each endpoint independently.
      api_get "/people/#{person.id}/?fields[people]=enabled"
      api_response.data.attributes.risk.should be_nil

      api_get "/people/#{person.id}"
      api_response.data.attributes.risk.should == 'medium'

      # After a raw non-callback calling update, results remain cached.
      person.update_column(:enabled, false)
      api_get "/people/#{person.id}/?fields[people]=enabled"
      api_response.data.attributes.enabled.should be_truthy
      api_get "/people/#{person.id}"
      api_response.data.attributes.enabled.should be_truthy 

      # After a regular callback-calling update both caches are expired
      person.update_attribute(:enabled, false)
      api_get "/people/#{person.id}/?fields[people]=enabled"
      api_response.data.attributes.enabled.should be_falsey
      api_get "/people/#{person.id}"
      api_response.data.attributes.enabled.should be_falsey
      Rails.application.config.cache_store = :null_store
    end
  end
end
