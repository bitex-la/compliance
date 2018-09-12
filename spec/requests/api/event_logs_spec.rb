require 'rails_helper'

describe EventLog do
  let(:admin_user) { create(:admin_user) }
  
  it 'listing event log' do 
    issue = create(:full_natural_person_issue, 
      person: create(:empty_person))

    get '/api/event_logs',
      params: { data: nil },
      headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

    response.status == 200
    assert_logging(Issue.first, verb, expected_count)
    json_response
    
=begin    
    json_response.should == {
      data {
        [

        ]
      }
    }
=end
    debugger
  end
end