require "rails_helper"
require "helpers/api/issues_helper"
require "helpers/api/api_helper"
require "json"

shared_examples "seed" do |type, initial_factory, later_factory, relations_proc = nil|
  initial_seed = "#{initial_factory}_seed"
  later_seed = "#{later_factory}_seed"
  seed_type = Garden::Naming.new(type).seed_plural

  it "Creates, updates and approves #{seed_type}" do
    issue = create(:basic_issue)
    person = issue.person

    initial_attrs = attributes_for(initial_seed)

    initial_relations, later_relations =
      if relations_proc
        instance_exec(&relations_proc)
      else
        [{}, {}]
      end

    issue_relation = { issue: { data: { id: issue.id.to_s, type: 'issues' } } }

    server_sent_relations = {
      person: {data: {id: person.id.to_s, type: 'people'}},
      attachments: {data: []},
      fruit: {data: nil},
    }

    api_create "/#{seed_type}", {
      type: seed_type,
      attributes: initial_attrs,
      relationships: issue_relation.merge(initial_relations)
    }

    seed = api_response.data
    seed.attributes.to_h.should >= initial_attrs

    json_response[:data][:relationships].should >=
      issue_relation
        .merge(initial_relations)
        .merge(server_sent_relations)

    later_attrs = attributes_for(later_seed)

    api_update "/#{seed_type}/#{seed.id}", {
      type: seed_type,
      attributes: later_attrs,
      relationships: later_relations
    }

    api_response.data.attributes.should >= later_attrs

    json_response[:data][:relationships].should >=
      issue_relation
        .merge(later_relations)
        .merge(server_sent_relations)

    api_request :post, "/issues/#{issue.id}/approve"

    api_get "/people/#{person.id}"
    fruit = json_response[:included].find { |i| i[:type] == type.to_s }
    fruit[:attributes].should >= later_attrs
    fruit[:relationships].should == later_relations.merge({
      person: {data: {id: person.id.to_s, type: "people"}},
      attachments: {data: []},
      replaced_by: {data: nil},
      seed: {data: {id: seed.id, type: seed_type.to_s}},
    })
  end

  it "Can't edit #{seed_type} once issue is closed" do
    later_attrs = attributes_for(later_seed)
    issue = create(:basic_issue)
    seed = create(initial_seed, issue: issue, copy_attachments: true,
                                add_all_attachments: false)

    issue.approve!

    initial_relations, later_relations =
      if relations_proc
        instance_exec(&relations_proc)
      else
        [{}, {}]
      end

    api_update "/#{seed_type}/#{seed.id}", {
      type: seed_type,
      attributes: later_attrs,
      relationships: later_relations
    }, 422
  end

  it "Can't add attachments to #{seed_type} once issue is closed" do
    pending
    fail
  end

  it "Allows filters on #{type} index" do
    pending
    fail
  end

  it "Allows filters on #{seed_type} index" do
    pending
    fail
  end
end

shared_examples "docket" do |type, initial_factory|
  initial_seed = "#{initial_factory}_seed"
  seed_type = Garden::Naming.new(type).seed_plural

  it "Replaces a #{type}, showing all resources involved" do
    person = create(:empty_person).reload
    # We need to create an issue for this person, so that the factory
    # for the fruit that follows it can create it's original seed and add
    # it to the existing issue.
    create(:basic_issue, person: person, aasm_state: "approved")
    old_attrs = attributes_for(initial_factory)
    old_fruit = create(initial_factory, person: person).reload

    issue = create(:basic_issue, person: person)
    seed = create(initial_seed, issue: issue, copy_attachments: true,
                                add_all_attachments: false)

    # The fruit has not been replaced yet
    api_get "/#{type}/#{old_fruit.id}"
    api_response
      .data.attributes.to_h.slice(*old_attrs.keys).should eq(old_attrs)

    json_response[:data][:relationships].should == {
      person: {data: {id: person.id.to_s, type: "people"}},
      replaced_by: {data: nil},
      seed: {data: {type: seed_type, id: old_fruit.seed.id.to_s}},
      attachments: {data: old_fruit.attachments.map { |a| {type: "attachments", id: a.id.to_s} }},
    }

    # The seed does not have a fruit yet.
    api_get "/#{seed_type}/#{seed.id}"
    api_response
      .data.attributes.to_h.slice(*old_attrs.keys).should eq(old_attrs)

    json_response[:data][:relationships].should == {
      issue: {data: {id: issue.id.to_s, type: "issues"}},
      person: {data: {id: person.id.to_s, type: "people"}},
      fruit: {data: nil},
      attachments: {data: []},
    }
    new_fruit_id = api_response.data.id

    # The person still has the old fruit
    api_get "/people/#{person.id}"
    json_response[:data][:relationships]
      .map { |k, v| v[:data] }.flatten.compact
      .select { |d| d[:type] == type.to_s }
      .map { |i| i[:id] }
      .should == [old_fruit.id.to_s]

    issue.approve!

    api_get "/#{type}/#{old_fruit.id}"
    json_response[:data][:relationships].should == {
      person: {data: {id: person.id.to_s, type: "people"}},
      replaced_by: {data: {id: new_fruit_id, type: type.to_s}},
      seed: {data: {id: old_fruit.seed.id.to_s, type: seed_type.to_s}},
      attachments: {data: []},
    }

    api_get "/#{type}/#{new_fruit_id}"
    json_response[:data][:relationships].should == {
      person: {data: {id: person.id.to_s, type: "people"}},
      replaced_by: {data: nil},
      seed: {data: {id: seed.id.to_s, type: seed_type.to_s}},
      attachments: {data: old_fruit.attachments.map { |a| {type: "attachments", id: a.id.to_s} }},
    }

    api_get "/#{seed_type}/#{seed.id}"
    json_response[:data][:relationships].should == {
      issue: {data: {id: issue.id.to_s, type: "issues"}},
      person: {data: {id: person.id.to_s, type: "people"}},
      fruit: {data: {id: new_fruit_id, type: type.to_s}},
      attachments: {data: []},
    }

    # The person now has the new fruit
    api_get "/people/#{person.id}"
    json_response[:data][:relationships]
      .map { |k, v| v[:data] }.flatten.compact
      .select { |d| d[:type] == type.to_s }
      .map { |i| i[:id] }
      .should == [new_fruit.id.to_s]
  end

  it "can choose to copy attachments when replacing #{type}" do
    pending
    fail
  end
end

shared_examples "has_many fruit" do |type, factory, relations_proc = nil|
  seed_factory = "#{factory}_seed"
  fruit_class =  Garden::Naming.new(type).fruit.constantize
  seed_type = Garden::Naming.new(type).seed_plural

  it "Adds multiple #{type}, explicitly replaces one of them" do
    person = create(:empty_person).reload
    # We need to create an issue for this person, so that the factory
    # for the fruit that follows it can create it's original seed and add
    # it to the existing issue.
    create(:basic_issue, person: person, aasm_state: "approved")
    attrs = attributes_for(factory)
    existing_fruit = create(factory, person: person).reload

    # Then a new fruit is added besides the existing one.
    issue = create(:basic_issue, person: person)
    issue_relation = { issue: { data: { id: issue.id.to_s, type: 'issues' } } }
    extra_relations = relations_proc ? instance_exec(&relations_proc) : {}

    api_create "/#{seed_type}", {
      type: seed_type,
      attributes: attrs,
      relationships: issue_relation.merge(extra_relations)
    }

    api_request :post, "/issues/#{issue.id}/approve"
    replaceable_fruit_id = fruit_class.last.id.to_s

    api_get "/people/#{person.id}"
    json_response[:data][:relationships][type.to_sym][:data]
      .map{|a| a[:id] }
      .should == [existing_fruit.id.to_s, replaceable_fruit_id]

    api_create "/#{seed_type}", {
      type: seed_type,
      attributes: initial_attrs,
      relationships: issue_relation.merge(extra_relations)
    }

    replacing_issue = create(:basic_issue, person: person)
    replacing_issue_relation =
      { issue: { data: { id: issue2.id.to_s, type: 'issues' } } }

    replacing_fruit_relations =
      { replaces: { data: { id: replaceable_fruit_id, type: type.to_s } } }

    api_create "/#{seed_type}", {
      type: seed_type,
      attributes: later_attrs,
      relationships: replacing_issue_relation
        .merge(replacing_fruit_relations)
        .merge(extra_relations)
    }
    api_response.data.relationships.replaces.id.should == replaceable_fruit_id

    api_request :post, "/issues/#{issue.id}/approve"
    replacement_fruit_id = fruit_class.last.id.to_s

    api_get "/people/#{person.id}"
    json_response[:data][:relationships][type][:data]
      .map{|a| a[:id] }
      .should == [existing_fruit.id.to_s, replacement_fruit_id]

    api_get "/#{type}/#{replaceable_fruit_id}"
    api_response.data.relationships.replaced_by.id.should == replacement_fruit_id
  end

  it "can choose to copy attachments when replacing #{type}" do
    pending
    fail
  end
end

describe 'All seed and fruit kinds' do
  it_behaves_like('seed', :natural_dockets,
                  :full_natural_docket, :alt_full_natural_docket)

  it_behaves_like('docket', :natural_dockets, :full_natural_docket)

  it_behaves_like('seed', :legal_entity_dockets,
                  :full_legal_entity_docket, :alt_full_legal_entity_docket)

  it_behaves_like('docket', :legal_entity_dockets, :full_legal_entity_docket)

  it_behaves_like('seed', :argentina_invoicing_details,
                  :full_argentina_invoicing_detail,
                  :alt_full_argentina_invoicing_detail)

  it_behaves_like('seed', :chile_invoicing_details,
                  :full_chile_invoicing_detail, :alt_full_chile_invoicing_detail)

  it_behaves_like('seed', :phones, :full_phone, :alt_full_phone)

  it_behaves_like('seed', :domiciles, :full_domicile, :alt_full_domicile)

  it_behaves_like('seed', :emails, :full_email, :alt_full_email)

  it_behaves_like('seed', :identifications,
                  :full_natural_person_identification,
                  :alt_full_natural_person_identification)

  it_behaves_like('seed', :allowances, :salary_allowance, :alt_salary_allowance)

  it_behaves_like('seed', :risk_scores, :full_risk_score, :alt_full_risk_score)

  it_behaves_like('seed', :notes, :full_note, :alt_full_note)

  it_behaves_like('seed', :affinities, :full_affinity, :alt_full_affinity, -> {
    [
      {related_person: {data:
        {id: create(:empty_person).id.to_s, type: 'people'}}},
      {related_person: {data:
        {id: create(:empty_person).id.to_s, type: 'people'}}},
    ]
  })

  it_behaves_like('has_many fruit', :argentina_invoicing_details,
    :full_argentina_invoicing_detail)

  it_behaves_like('has_many fruit', :chile_invoicing_details,
    :full_chile_invoicing_detail)

  it_behaves_like('has_many fruit', :phones, :full_phone, :alt_full_phone)

  it_behaves_like('has_many fruit', :domiciles, :full_domicile)

  it_behaves_like('has_many fruit', :emails, :full_email)

  it_behaves_like('has_many fruit', :identifications,
    :full_natural_person_identification)

  it_behaves_like('has_many fruit', :allowances, :salary_allowance)

  it_behaves_like('has_many fruit', :risk_scores, :full_risk_score)

  it_behaves_like('has_many fruit', :notes, :full_note)

  it_behaves_like('has_many fruit', :affinities, :full_affinity, -> {
    { related_person: {
        data: {id: create(:empty_person).id.to_s, type: 'people'}
      }
    }
  })
end
