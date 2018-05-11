require 'rails_helper'
require 'helpers/api/issues_helper'
require 'json'

%w(
  AffinitySeed
).each do |seed|
  describe seed.constantize do
    let(:issue) {create(:basic_issue)}
    let(:admin_user) { create(:admin_user) } 

    describe "Creating a new #{seed}" do
      it "creates a new #{seed} with an attachment" do
        if seed == 'AffinitySeed'
          related_person = create(:empty_person)
          related_person.save
          seed_payload = Api::SeedsHelper.affinity_seed(issue, related_person, :png)
        else

        end

        post "/api/people/#{issue.person.id}/issues/#{issue.id}/#{seed.pluralize.underscore}",
          params: seed_payload,
          headers: { 'Authorization': "Token token=#{admin_user.api_token}" }
          
        assert_response 201 
      end
    end
  end
end


