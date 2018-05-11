require 'rails_helper'
require 'helpers/api/issues_helper'
require 'json'

PLURAL_SEEDS = %w(
  AffinitySeed
  PhoneSeed
  DomicileSeed
  EmailSeed
  IdentificationSeed
  AllowanceSeed
  NoteSeed
)

SINGULAR_SEEDS = %w(
  NaturalDocketSeed
  LegalEntityDocketSeed
)

%w(
  AffinitySeed
  PhoneSeed
  DomicileSeed
  EmailSeed
  IdentificationSeed
  AllowanceSeed
  NoteSeed
).each do |seed|
  describe seed.constantize do
    let(:issue) {create(:basic_issue)}
    let(:admin_user) { create(:admin_user) } 

    describe "Creating a new #{seed}" do
      it "creates a new #{seed} with an attachment" do
        seed_payload = if seed == 'AffinitySeed'
          related_person = create(:empty_person)
          related_person.save
          Api::SeedsHelper.affinity_seed(issue, related_person, :png)
        else
          Api::SeedsHelper.send(seed.underscore.to_sym, issue, :png)
        end

        relationship = seed.pluralize.underscore

        post "/api/people/#{issue.person.id}/issues/#{issue.id}/#{relationship}",
          params: seed_payload,
          headers: { 'Authorization': "Token token=#{admin_user.api_token}" }
         
        assert_response 201
        issue.send("#{relationship}").count.should == 1
        issue.send("#{relationship}").first.attachments.count.should == 1
      end
    end
  end
end


