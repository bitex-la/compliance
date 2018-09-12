require 'rails_helper'

describe EventLog do
  let(:admin_user) { create(:admin_user) }
  
  it 'listing event log' do 
    person = create(:empty_person)
    Timecop.travel 10.minutes.from_now
    issue = create(:full_natural_person_issue, person: person)

    get '/api/event_logs?page[page]=1&page[per_page]=1',
      params: { data: nil },
      headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

    response.status == 200
    assert_logging(issue, :create_entity, 1)
    assert_logging(person, :create_entity, 1)
    
    api_response.data.count.should == 1
    api_response.meta.total_pages.should == 3 
    api_response.data.first.id.should == EventLog.last.id.to_s

    get '/api/event_logs?page[page]=3&page[per_page]=1',
      headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

    api_response.data.count.should == 1
    api_response.meta.total_pages.should == 3
    api_response.data.first.id.should == EventLog.first.id.to_s
  end

  it 'listing event log, adding a filter' do 
    person = create(:empty_person)
    Timecop.travel 10.minutes.from_now
    issue = create(:full_natural_person_issue, person: person)

    get '/api/event_logs?filter[entity_type]=Issue&filter[verb]=create_entity',
      headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

    response.status == 200
    assert_logging(issue, :create_entity, 1)
    
    api_response.data.count.should == 1
    api_response.meta.total_pages.should == 1 
    api_response.data.first.attributes.entity_id.should == issue.id
    api_response.data.first.attributes.entity_type.should == "Issue"
  end
end