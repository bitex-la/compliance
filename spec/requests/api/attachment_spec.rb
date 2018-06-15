require 'rails_helper'
require 'helpers/api/issues_helper'
require 'helpers/api/api_helper'
require 'json'

ALL_SEEDS.each do |seed|
  describe seed.constantize do
    let(:issue) {create(:basic_issue)}
    let(:admin_user) { create(:admin_user) }
    let(:relationship) do 
      PLURAL_SEEDS.include?(seed) ? seed.pluralize.underscore : seed.underscore
    end

    describe "Creating a new #{seed}" do
      it "creates a new #{seed} with an attachment and adds a new file" do
        seed_payload = build_seed_payload(seed)

        post "/api/people/#{issue.person.id}/issues/#{issue.id}/#{seed.pluralize.underscore}",
          params: seed_payload,
          headers: { 'Authorization': "Token token=#{admin_user.api_token}" }
        
        assert_response 201

        issue.reload
        seed_id = if PLURAL_SEEDS.include? seed
          issue.send(relationship).first.id
        else
          issue.send(relationship).id
        end

        post "/api/people/#{issue.person.id}/issues/#{issue.id}/#{seed.pluralize.underscore}/#{seed_id}/attachments",
          params: Api::IssuesHelper.seed_attachment_payload(
            :zip, 
            '@1', 
            issue.person.id, 
            seed_id,
            seed.pluralize.underscore
          ),
          headers: { 'Authorization': "Token token=#{admin_user.api_token}" }
      
        assert_response 201
        
        if PLURAL_SEEDS.include? seed
          issue.send(relationship).first.attachments.count.should == 2
          attachment_id = issue.send(relationship).first.attachments.last.id
        else
          issue.send(relationship).attachments.count.should == 2
          attachment_id = issue.send(relationship).attachments.last.id
        end

        get "/api/people/#{issue.person.id}/issues/#{issue.id}/#{seed.pluralize.underscore}/#{seed_id}/attachments/#{attachment_id}",
          headers: { 'Authorization': "Token token=#{admin_user.api_token}" } 

        assert_response 200

        attachment_data = json_response[:data][:attributes]
        attachment_data[:document_content_type].should == 'application/zip'
        attachment_data[:document_file_name].should == 'file.zip'
      end

      it "creates a new #{seed} with an attachment, then update the file using the attachment endpoint" do
        seed_payload = build_seed_payload(seed)

        post "/api/people/#{issue.person.id}/issues/#{issue.id}/#{seed.pluralize.underscore}",
          params: seed_payload,
          headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

        assert_response 201
        issue.reload
        seed_id = if PLURAL_SEEDS.include? seed
          issue.send(relationship).first.id
        else
          issue.send(relationship).id
        end

        if PLURAL_SEEDS.include? seed
          attachment_id = issue.send(relationship).first.attachments.last.id
        else
          attachment_id = issue.send(relationship).attachments.last.id
        end

        put "/api/people/#{issue.person.id}/issues/#{issue.id}/#{seed.pluralize.underscore}/#{seed_id}/attachments/#{attachment_id}",
          params: Api::IssuesHelper.seed_attachment_payload(
            :gif, 
            attachment_id, 
            issue.person.id, 
            seed_id,
            seed.pluralize.underscore
          ),
          headers: { 'Authorization': "Token token=#{admin_user.api_token}" } 

        assert_response 200
       
        if PLURAL_SEEDS.include? seed
          issue.send(relationship).first.attachments.count.should == 1
        else
          issue.send(relationship).attachments.count.should == 1
        end

        json_response[:data][:id].should == attachment_id.to_s
        attachment_data = json_response[:data][:attributes]
        attachment_data[:document_content_type].should == 'image/gif'
        attachment_data[:document_file_name].should == 'file.gif'
      end
    end
  end
end

