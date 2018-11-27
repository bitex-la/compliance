# These shared examples exercise features common to all json-api endpoints
shared_examples "seed" do |type, initial_factory, later_factory,
  relations_proc = -> { {} }|

  initial_seed = "#{initial_factory}_seed"
  later_seed = "#{later_factory}_seed"
  seed_type = Garden::Naming.new(type).seed_plural

  it "Destroy a #{seed_type}" do
    seed = create(initial_seed, issue: create(:basic_issue))
    api_destroy "/#{seed_type}/#{seed.id}"
    
    response.body.should be_blank

    api_get "/#{seed_type}/#{seed.id}", {}, 404
  end
   
  it "Creates, updates and approves #{seed_type}" do
    issue = create(:basic_issue)
    person = issue.person

    initial_attrs = attributes_for(initial_seed)

    initial_relations = instance_exec(&relations_proc)
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
    later_relations = instance_exec(&relations_proc)

    api_update "/#{seed_type}/#{seed.id}", {
      type: seed_type,
      attributes: later_attrs,
      relationships: later_relations
    }

    seed_id = api_response.data.id

    api_response.data.attributes.should >= later_attrs
    json_response[:data][:relationships].should >=
      issue_relation
        .merge(later_relations)
        .merge(server_sent_relations)

    file_one, file_two = %i(gif png).map do |ext|
      api_create "/attachments", jsonapi_attachment(seed_type, seed_id, ext)
      api_response.data
    end

    api_request :post, "/issues/#{issue.id}/approve"

    api_get "/people/#{person.id}"
    fruit = json_response[:included].find { |i| i[:type] == type.to_s }
    fruit[:attributes].should >= later_attrs
    fruit[:relationships].should == later_relations.merge({
      person: {data: {id: person.id.to_s, type: "people"}},
      attachments: {data: [
        { type: 'attachments', id: file_one.id },
        { type: 'attachments', id: file_two.id },
      ]},
      replaced_by: {data: nil},
      seed: {data: {id: seed.id, type: seed_type.to_s}},
    })
  end
end

shared_examples "docket" do |type, initial_factory|
  initial_seed = "#{initial_factory}_seed"
  seed_type = Garden::Naming.new(type).seed_plural
  fruit_class = Garden::Naming.new(type).fruit.constantize

  it "Replaces a #{type}, showing all resources involved" do
    person = create(:empty_person).reload
    # We need to create an issue for this person, so that the factory
    # for the fruit that follows it can create it's original seed and add
    # it to the existing issue.
    create(:basic_issue, person: person, aasm_state: "approved")
    old_attrs = attributes_for(initial_factory)
    old_fruit = create(initial_factory, person: person).reload

    issue = create(:basic_issue, person: person)
    seed = create(initial_seed, issue: issue)

    # The fruit has not been replaced yet
    api_get "/#{type}/#{old_fruit.id}"
    api_response
      .data.attributes.to_h.slice(*old_attrs.keys).should eq(old_attrs)

    json_response[:data][:relationships].should >= {
      person: {data: {id: person.id.to_s, type: "people"}},
      replaced_by: {data: nil},
      seed: {data: {type: seed_type, id: old_fruit.seed.id.to_s}}
    }

    # The seed does not have a fruit yet.
    api_get "/#{seed_type}/#{seed.id}"
    api_response
      .data.attributes.to_h.slice(*old_attrs.keys).should eq(old_attrs)

    json_response[:data][:relationships].should >= {
      issue: {data: {id: issue.id.to_s, type: "issues"}},
      person: {data: {id: person.id.to_s, type: "people"}},
      fruit: {data: nil},
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
    json_response[:data][:relationships].should >= {
      person: {data: {id: person.id.to_s, type: "people"}},
      replaced_by: {data: {id: new_fruit_id, type: type.to_s}},
      seed: {data: {id: old_fruit.seed.id.to_s, type: seed_type.to_s}},
    }

    api_get "/#{type}/#{new_fruit_id}"
    json_response[:data][:relationships].should >= {
      person: {data: {id: person.id.to_s, type: "people"}},
      replaced_by: {data: nil},
      seed: {data: {id: seed.id.to_s, type: seed_type.to_s}},
    }

    api_get "/#{seed_type}/#{seed.id}"
    json_response[:data][:relationships].should >= {
      issue: {data: {id: issue.id.to_s, type: "issues"}},
      person: {data: {id: person.id.to_s, type: "people"}},
      fruit: {data: {id: new_fruit_id, type: type.to_s}},
    }

    # The person now has the new fruit
    api_get "/people/#{person.id}"
    json_response[:data][:relationships]
      .map { |k, v| v[:data] }.flatten.compact
      .select { |d| d[:type] == type.to_s }
      .map { |i| i[:id] }
      .should == [new_fruit_id]
  end

  it "Can copy previous attachments to new #{type}" do
    person = create(:empty_person).reload
    create(:basic_issue, person: person, aasm_state: "approved")
    existing_fruit = create(initial_factory, person: person).reload

    api_get "/#{type}/#{existing_fruit.id}"
    old_attachments = api_response.data.relationships.attachments

    issue = create(:basic_issue, person: person)

    api_create "/#{seed_type}", {
      type: seed_type,
      attributes: attributes_for(initial_seed, copy_attachments: true),
      relationships: {
        issue: {data: {id: issue.id.to_s, type: 'issues'}},
      }
    }

    api_request :post, "/issues/#{issue.id}/approve"
    new_fruit_id = fruit_class.last.id.to_s

    api_get "/#{type}/#{new_fruit_id}"
    api_response.data.relationships.attachments.should == old_attachments
  end

  it "Can add #{type} attachments that replace old ones" do
    person = create(:empty_person).reload
    # We need to create an issue for this person, so that the factory
    # for the fruit that follows it can create it's original seed and add
    # it to the existing issue.
    create(:basic_issue, person: person, aasm_state: "approved")
    existing_fruit = create(initial_factory, person: person).reload

    issue = create(:basic_issue, person: person)

    api_create "/#{seed_type}", {
      type: seed_type,
      attributes: attributes_for(initial_seed),
      relationships: {issue: {data: {id: issue.id.to_s, type: 'issues'}}}
    }
    seed_id = api_response.data.id

    api_create "/attachments", jsonapi_attachment(seed_type, seed_id)
    attachment = api_response.data

    api_request :post, "/issues/#{issue.id}/approve"

    new_fruit_id = fruit_class.last.id.to_s

    api_get "/#{type}/#{new_fruit_id}"
    api_response.data.relationships.attachments.data.map(&:id).should ==
      [attachment.id]
  end
end

shared_examples "has_many fruit" do |type, factory, relations_proc = -> { {} }, new_attrs = {}|
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

    replacing_issue = create(:basic_issue, person: person)
    replacing_issue_relation =
      { issue: { data: { id: replacing_issue.id.to_s, type: 'issues' } } }

    replacing_fruit_relations =
      { replaces: { data: { id: replaceable_fruit_id, type: type.to_s } } }

    api_create "/#{seed_type}", {
      type: seed_type,
      attributes: attrs.merge!(new_attrs),
      relationships: replacing_issue_relation
        .merge(replacing_fruit_relations)
        .merge(extra_relations)
    }

    api_response.data.relationships.replaces.data.id.should ==
      replaceable_fruit_id

    api_request :post, "/issues/#{replacing_issue.id}/approve"
    replacement_fruit_id = fruit_class.last.id.to_s

    api_get "/people/#{person.id}"
    json_response[:data][:relationships][type][:data]
      .map{|a| a[:id] }
      .should == [existing_fruit.id.to_s, replacement_fruit_id]

    api_get "/#{type}/#{replaceable_fruit_id}"
    api_response.data.relationships.replaced_by.data.id.should ==
      replacement_fruit_id
  end

  it "Can copy previous attachments to new #{type}" do
    person = create(:empty_person).reload
    # We need to create an issue for this person, so that the factory
    # for the fruit that follows it can create it's original seed and add
    # it to the existing issue.
    create(:basic_issue, person: person, aasm_state: "approved")
    existing_fruit = create(factory, person: person).reload

    api_get "/#{type}/#{existing_fruit.id}"
    old_attachments = api_response.data.relationships.attachments

    issue = create(:basic_issue, person: person)
    relationships = instance_exec(&relations_proc).merge({
      issue: {data: {id: issue.id.to_s, type: 'issues'}},
      replaces: {data: {id: existing_fruit.id.to_s, type: type.to_s }}
    })

    api_create "/#{seed_type}", {
      type: seed_type,
      attributes: attributes_for(seed_factory, copy_attachments: true),
      relationships: relationships
    }

    api_request :post, "/issues/#{issue.id}/approve"

    new_fruit_id = fruit_class.last.id.to_s

    api_get "/#{type}/#{new_fruit_id}"
    api_response.data.relationships.attachments.should == old_attachments
  end

  it "Can add #{type} attachments that replace old ones" do
    person = create(:empty_person).reload
    # We need to create an issue for this person, so that the factory
    # for the fruit that follows it can create it's original seed and add
    # it to the existing issue.
    create(:basic_issue, person: person, aasm_state: "approved")
    existing_fruit = create(factory, person: person).reload

    issue = create(:basic_issue, person: person)
    relationships = instance_exec(&relations_proc).merge({
      issue: {data: {id: issue.id.to_s, type: 'issues'}},
      replaces: {data: {id: existing_fruit.id.to_s, type: type.to_s }}
    })

    api_create "/#{seed_type}", {
      type: seed_type,
      attributes: attributes_for(seed_factory),
      relationships: relationships
    }
    seed_id = api_response.data.id

    api_create "/attachments", jsonapi_attachment(seed_type, seed_id)
    attachment = api_response.data

    api_request :post, "/issues/#{issue.id}/approve"

    new_fruit_id = fruit_class.last.id.to_s

    api_get "/#{type}/#{new_fruit_id}"
    api_response.data.relationships.attachments.data.map(&:id).should ==
      [attachment.id]
  end
end

shared_examples "jsonapi show and index" do |type, factory_one, factory_two,
  filter_matching_factory_two,
  fields_definition,
  include_definition,
  relations_proc = -> { {} }|

  before(:each){
    @one = create(factory_one)
    Timecop.travel 10.minutes.from_now
    @two = create(factory_one)
    Timecop.travel 10.minutes.from_now
    @three = create(factory_two)
  }

  it "Show #{type} index oldest first" do
    api_get "/#{type}"
    api_response.data.map{|i| i.id.to_i }.first.should == @three.id
    api_response.data.map{|i| i.id.to_i }.last.should == @two.id
  end

  it "Can paginate on #{type} index" do
    api_get "/#{type}", {page: {page: 3, per_page: 1}}
    api_response.meta.total_pages.should == 4
    api_response.meta.total_items.should == 4
  end

  it "Can filter on #{type} index" do
    api_get "/#{type}", {filter: filter_matching_factory_two}
    api_response.data.map(&:id).first.should == @three.id.to_s
  end

  it "Can customize fields on #{type} index" do
    api_get "/#{type}", {fields: { type => fields_definition}}
    json_response[:data].map do |d|
      d[:attributes].keys.map(&:to_s) + 
      (d[:relationships] || {}).keys.map(&:to_s)
    end.flatten.uniq.should == fields_definition.split(',')
  end

  it "Can customize includes on #{type} index" do
    api_get "/#{type}", {include: include_definition}

    expected = include_definition.split(',').map do |i|
      json_response[:data].map do |d|
        [d[:relationships][i.to_sym][:data]].flatten
      end
    end.flatten

    json_response.fetch(:included, [])
      .map{|i| i.slice(:id, :type) }.to_set.should == expected.to_set
  end

  it "Can customize fields on #{type} show" do
    api_get "/#{type}/#{@one.id}", {fields: { type => fields_definition}}
    json_response[:data]
      .values_at(:attributes, :relationships).compact
      .map{|i| i.keys.map(&:to_s) }.flatten
      .to_set.should == fields_definition.split(',').to_set
  end

  it "Can customize includes on #{type} show" do
    api_get "/#{type}/#{@one.id}", {include: include_definition}

    expected = include_definition.split(',').map do |i|
      json_response[:data][:relationships][i.to_sym][:data]
    end.flatten.to_set

    json_response.fetch(:included, [])
      .map{|i| i.slice(:id, :type) }.to_set.should == expected
  end
end
