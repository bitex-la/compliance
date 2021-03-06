require 'rails_helper'

describe Attachment do 
  it "attaches a few files" do
    issue = create(:basic_issue)
    seed = create(:full_natural_docket_seed,
      issue: issue, add_all_attachments: false)

    file_one, file_two = %i(gif png).map do |ext|
      api_create "/attachments",
        jsonapi_attachment('natural_docket_seeds', seed.id.to_s, ext)
      api_response.data
    end

    api_get "/attachments/#{file_one.id}"
    api_response.data.relationships.attached_to_seed.data.to_h.should == {
      type: 'natural_docket_seeds', id: seed.id.to_s
    }
  end

  it 'handles malicious specially-crafted images' do
    issue = create(:basic_issue)
    seed = create(:full_natural_docket_seed,
      issue: issue, add_all_attachments: false)

    fixtures = RSpec.configuration.file_fixture_path
    
    path = Pathname.new(File.join(fixtures, "lottapixel.jpg"))
    base64 = Base64.encode64(path.read).delete!("\n")

    api_create "/attachments",
      jsonapi_base64_attachment('natural_docket_seeds', seed.id.to_s, base64, :jpg)
  end

  it 'attaches a file with a large base64 encoded image' do
    issue = create(:basic_issue)
    seed = create(:full_natural_docket_seed,
      issue: issue, add_all_attachments: false)

    fixtures = RSpec.configuration.file_fixture_path
  
    file_one, file_two = %i(one two).map do |file|
      base64 = Pathname.new(File.join(fixtures, "base64_#{file}_image.txt")).read
      api_create "/attachments",
        jsonapi_base64_attachment('natural_docket_seeds', seed.id.to_s, base64, :jpeg)
      api_response.data
    end
  end

  it "can validate max people request limit on show" do
    one, two, three, four, five = 5.times.map do
      seed = create(:full_natural_docket_seed_with_person)
      api_create "/attachments",
        jsonapi_attachment('natural_docket_seeds', seed.id.to_s, :jpg)
      api_response.data
    end

    create(:limited_people_allowed_admin_user)

    api_get "/attachments/#{one.id}"
    api_get "/attachments/#{two.id}"
    api_get "/attachments/#{three.id}"

    api_get "/attachments/#{four.id}", {}, 403
    api_get "/attachments/#{five.id}", {}, 403

    api_get "/attachments/#{one.id}"
    api_get "/attachments/#{two.id}"
    api_get "/attachments/#{three.id}"
  end

  describe "when re-arranging attachments" do
    it "can be re-attached to a fruit" do
      pending
      fail
    end

    it "cannot be re-attached to a fruit from a different person" do
      pending
      fail
    end

    it "can be re-attached to a seed" do
      pending
      fail
    end

    it "cannot be re-attached to a seed from a different person" do
      pending
      fail
    end
  end    
end
