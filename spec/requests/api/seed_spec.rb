require 'rails_helper'
require 'helpers/api/issues_helper'
require 'helpers/api/api_helper'
require 'json'

shared_examples 'seed' do |type, has_many, initial_factory, later_factory, relations_proc = nil|
  initial_seed = "#{initial_factory}_seed"
  later_seed = "#{later_factory}_seed"
  seed_type = Garden::Naming.new(type).seed_plural

  it "Creates, updates and approves #{seed_type}" do
    issue = create(:basic_issue)
    person = issue.person

    initial_attrs = attributes_for(initial_seed)

    initial_relations, later_relations = if relations_proc
      instance_exec(&relations_proc)
    else
      [{},{}]
    end

    issue_relation = { issue: { data: { id: issue.id.to_s, type: 'issues' } } }

    server_sent_relations = {
        person: { data: { id: person.id.to_s, type: 'people' } },
        attachments: { data: [] },
        fruit: { data: nil }
    }

    api_create "/#{seed_type}", {
      type: seed_type,
      attributes: initial_attrs,
      relationships: issue_relation.merge(initial_relations)
    }

    seed = api_response.data

    seed
      .attributes.to_h
      .slice(*initial_attrs.keys)
      .should eq(initial_attrs)

    json_response[:data][:relationships].should == issue_relation
      .merge(initial_relations)
      .merge(server_sent_relations)

    later_attrs = attributes_for(later_seed)

    api_update "/#{seed_type}/#{seed.id}", {
      type: seed_type,
      attributes: later_attrs,
      relationships: later_relations
    }

    api_response
      .data.attributes.to_h.slice(*later_attrs.keys)
      .should eq(later_attrs)

    json_response[:data][:relationships].should == issue_relation
      .merge(later_relations)
      .merge(server_sent_relations)

    api_request :post, "/issues/#{issue.id}/approve"

    api_get "/people/#{person.id}"

    fruit = json_response[:included].find { |i| i[:type] == type.to_s }
    fruit[:attributes].slice(*later_attrs.keys).should == later_attrs
    fruit[:relationships].should == later_relations.merge({
      person: { data: { id: person.id.to_s, type: 'people' } },
      attachments: { data: [] },
      replaced_by: { data: nil },
      seed: { data: { id: seed.id, type: seed_type.to_s } }
    })
  end
end

shared_examples 'has_many_seed' do |type, has_many, initial_factory, later_factory, relations_proc = nil|
  initial_seed = "#{initial_factory}_seed"
  later_seed = "#{later_factory}_seed"
  seed_type = Garden::Naming.new(type).seed_plural

  it "Adds several new #{type}" do
    fruit = create(initial_factory)

    issue = create(:basic_issue)
    person = issue.person

    api_get "/#{seed_type}/#{seed.id}"
    api_response
      .data.attributes.to_h.slice(*later_attrs.keys)
      .should eq(later_attrs)
    json_response[:data][:relationships].should == all_later_seed_relations

    api_get "/#{seed_type}/#{seed.id}"
    json_response[:data][:relationships][:fruit].should ==
      { data: { id: fruit[:id], type: type.to_s } }

    api_get "/#{type}/#{fruit[:id]}"
    json_response[:data][:relationships][:seed].should ==
      { data: { id: seed.id, type: seed_type.to_s } }


    ####

    person = create(:empty_person).reload
    create(:basic_issue, person: person, aasm_state: 'approved')
    replaced = create(initial_factory, person: person)

    issue = create(:basic_issue, person: person)
    attrs = attributes_for(initial_seed)

    relationships = { issue: { data: { id: issue.id, type: 'issues' } } }
    if has_many
      relationships[:replaces] = { data: { id: replaced.id, type: type } }
    end

    api_create "/#{seed_type}", {
      type: seed_type,
      attributes: attrs,
      relationships: relationships
    }

    api_request :post, "/issues/#{issue.id}/approve"

    api_get "/people/#{person.id}"

    docket = api_response.included.find { |i| i.type == type.to_s }

    replaced.reload.replaced_by_id.should eq(docket.id.to_i)

    docket.attributes.to_h.slice(*attrs.keys).should == attrs
  end

  it "Replaces existing #{type}" do
    pending
    fail
  end
end

shared_examples 'docket' do |type, initial_factory|
  initial_seed = "#{initial_factory}_seed"
  seed_type = Garden::Naming.new(type).seed_plural

  it "Replaces a #{type}" do
    person = create(:empty_person).reload
    # We need to create an issue for this person, so that the factory
    # for the fruit that follows it can create it's original seed and add
    # it to the existing issue.
    create(:basic_issue, person: person, aasm_state: 'approved')
    replaced = create(initial_factory, person: person)

    issue = create(:basic_issue, person: person)
    seed = create(initial_seed, issue: issue)

    # El fruto 'replaced' todavía no tiene replaced_by
    # El seed todavía no tiene fruit
    # La persona incluye el viejo fruto
    #
    # approve!
    #
    # El fruto 'replaced' ahora apunta a su reemplazo
    # El seed apunta a su fruto
    # El fruto nuevo apunta a su seed y su reemplazado
    # La persona incluye el nuevo fruto
    # La persona no incluye el viejo fruto
    api_request :post, "/issues/#{issue.id}/approve"

    api_get "/people/#{person.id}"

    docket = api_response.included.find { |i| i.type == type.to_s }

    replaced.reload.replaced_by_id.should eq(docket.id.to_i)

    docket.attributes.to_h.slice(*attrs.keys).should == attrs
  end
end
  

describe 'All seed and fruit kinds' do
  it_behaves_like('seed', :natural_dockets, false,
                  :full_natural_docket, :alt_full_natural_docket)

  it_behaves_like('docket', :natural_dockets, :full_natural_docket)

  it_behaves_like('seed', :legal_entity_dockets, false,
                  :full_legal_entity_docket, :alt_full_legal_entity_docket)

  it_behaves_like('docket', :legal_entity_dockets, :full_legal_entity_docket)

  it_behaves_like('seed', :argentina_invoicing_details, true,
                  :full_argentina_invoicing_detail,
                  :alt_full_argentina_invoicing_detail)

  it_behaves_like('seed', :chile_invoicing_details, true,
                  :full_chile_invoicing_detail, :alt_full_chile_invoicing_detail)

  it_behaves_like('seed', :phones, true, :full_phone, :alt_full_phone)

  it_behaves_like('seed', :domiciles, true, :full_domicile, :alt_full_domicile)

  it_behaves_like('seed', :emails, true, :full_email, :alt_full_email)

  it_behaves_like('seed', :identifications, true,
                  :full_natural_person_identification,
                  :alt_full_natural_person_identification)

  it_behaves_like('seed', :allowances, true, :salary_allowance,
                  :alt_salary_allowance)

  it_behaves_like('seed', :risk_scores, true, :full_risk_score,
                  :alt_full_risk_score)

  it_behaves_like('seed', :notes, true, :full_note, :alt_full_note)

  it_behaves_like('seed', :affinities, true, :full_affinity, :alt_full_affinity, -> {
    [
      { related_person: { data: { id: create(:empty_person).id, type: 'people' } } },
      { related_person: { data: { id: create(:empty_person).id, type: 'people' } } },
    ]
  })
end

describe "when creating updating and approving" do
  it "Can create more than one" do
    pending
    fail
  end

  it "Cannot create more than one" do
    pending
    fail
  end

  it "Can add attachments" do
    pending
    fail
  end

  it "Can't add attachments once issue is closed" do
    pending
    fail
  end

  it "Can't edit once issue is closed" do
    pending
    fail
  end

  it "Allows filtering and showing fruit" do
    pending
    fail
  end

  it "Allows filtering and showing seed" do
    pending
    fail
  end
end
