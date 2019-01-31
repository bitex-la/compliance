require 'rails_helper'

describe Issue do
  
  describe 'When fetching current issue' do
    it 'includes relationships' do
      person = create :empty_person
      issue = create(:full_natural_person_issue, person: person)

      public_api_get person.api_token, "/issues/current"

      api_response.included
        .group_by{|i| i.type }
        .map{|a,b| [a, b.count ] }.to_h
        .should >= {
          "affinity_seeds"=>1,
          "email_seeds"=>1,
          "identification_seeds"=>1,
          "natural_docket_seeds"=>1,
          "domicile_seeds"=>1,
          "phone_seeds"=>1,
          "argentina_invoicing_detail_seeds"=>1,
          "allowance_seeds"=>2,
          "note_seeds"=>1, #Only 1 note is public, the other one is private
        }

      #Not public relationships
      %i(risk_score_seeds, people).each do |relationship|
        api_response.data.relationships.send(relationship).should be_nil
      end
      api_response.included.find { |x| x.type == 'note_seeds' }.attributes.private.should be_nil
    end

    it 'can include only public relationships' do
      person = create :empty_person
      issue = create(:full_natural_person_issue, person: person)

      %w(risk_score_seeds, people).each do |relationship|
        public_api_get person.api_token,
          "/issues/current?include=#{relationship}", {}, 422
      end

      public_api_get person.api_token, '/issues/current?include=email_seeds'
      api_response.included
        .group_by{|i| i.type }
        .map{|a,b| [a, b.count ] }.to_h
        .should == {
          "email_seeds"=>1
        }
    end

    it 'only displays client observations' do
      person = create :empty_person
      issue = create(:full_natural_person_issue, person: person)
      client_observation = create(:observation, issue: issue)
      robot_observation = create(:robot_observation, issue: issue)

      public_api_get person.api_token, "/issues/current"

      api_response.data.relationships.observations.data.tap do |observations|
        observations.count.should == 1
        observations.first.id.should == client_observation.id.to_s
      end
      api_response.included.select {
        |x| x.type == "observations"
      }.count.should == 1
    end
  end

  describe "when completing" do
    it "It can complete issue" do
      person = create :empty_person
      issue = create(:basic_issue, state: :draft, person: person)
      public_api_request person.api_token, :post, "/issues/#{issue.id}/complete", {}, 200
      issue.reload.state.should == "new"
    end

    it "It cannot complete approved issue" do
      person = create :empty_person
      issue = create(:basic_issue, state: :approved, person: person)
      public_api_request person.api_token, :post, "/issues/#{issue.id}/complete", {}, 404
    end
  end
end
