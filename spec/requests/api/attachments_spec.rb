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

  it "Can validate max people request limit on show" do
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

    api_get "/attachments/#{four.id}", {}, 400
    api_get "/attachments/#{five.id}", {}, 400

    api_get "/attachments/#{one.id}"
    api_get "/attachments/#{two.id}"
    api_get "/attachments/#{three.id}"
  end

  describe "When filter by admin tags" do
    let(:admin_user) { create(:admin_user) }

    before :each do
      admin_user.tags.clear
      admin_user.save!
    end

    it "allow attachment creation only with person valid admin tags" do
      person1 = create(:full_person_tagging).person
      person2 = create(:alt_full_person_tagging).person

      admin_user.tags << person1.tags.first
      admin_user.save!

      issue1 = create(:basic_issue, person: person1)
      issue2 = create(:basic_issue, person: person2)

      seed1 = create(:full_natural_docket_seed,
        issue: issue1, add_all_attachments: false)
      seed2 = create(:full_natural_docket_seed,
        issue: issue2, add_all_attachments: false)

      expect do
        api_create "/attachments",
          jsonapi_attachment('natural_docket_seeds', seed1.id.to_s, :png)
      end.to change { Attachment.count }.by(1)

      expect do
        api_create "/attachments",
          jsonapi_attachment('natural_docket_seeds', seed2.id.to_s, :png), 404
      end.to change { Attachment.count }.by(0)
    end

    it "allow attachment creation with person tags if admin has no tags" do
      person = create(:full_person_tagging).person
      issue = create(:basic_issue, person: person)
      seed = create(:full_natural_docket_seed,
        issue: issue, add_all_attachments: false)

      expect do
        api_create "/attachments",
          jsonapi_attachment('natural_docket_seeds', seed.id.to_s, :png)
      end.to change { Attachment.count }.by(1)
    end

    it "allow attachment creation without person tags if admin has no tags" do
      person = create(:empty_person)

      issue = create(:basic_issue, person: person)
      seed = create(:full_natural_docket_seed,
        issue: issue, add_all_attachments: false)

      expect do
        api_create "/attachments",
          jsonapi_attachment('natural_docket_seeds', seed.id.to_s, :png)
      end.to change { Attachment.count }.by(1)
    end

    it "allow attachment creation without person tags if admin has tags" do
      person = create(:full_person_tagging).person
      issue = create(:basic_issue, person: person)
      seed = create(:full_natural_docket_seed,
        issue: issue, add_all_attachments: false)

      admin_user.tags << person.tags.first
      admin_user.save!

      expect do
        api_create "/attachments",
          jsonapi_attachment('natural_docket_seeds', seed.id.to_s, :png)
      end.to change { Attachment.count }.by(1)
    end

    it "show attachment with admin user active tags" do
      person1 = create(:full_person_tagging).person
      person2 = create(:empty_person)
      person3 = create(:alt_full_person_tagging).person

      issue1 = create(:basic_issue, person: person1)
      issue2 = create(:basic_issue, person: person2)
      issue3 = create(:basic_issue, person: person3)

      seed1 = create(:full_natural_docket_seed,
        issue: issue1, add_all_attachments: false)
      seed2 = create(:full_natural_docket_seed,
        issue: issue2, add_all_attachments: false)
      seed3 = create(:full_natural_docket_seed,
        issue: issue3, add_all_attachments: false)

      att1 = create(:jpg_attachment, thing: seed1)
      att2 = create(:jpg_attachment, thing: seed2)
      att3 = create(:jpg_attachment, thing: seed3)

      api_get("/attachments/#{att1.id}")
      api_get("/attachments/#{att2.id}")
      api_get("/attachments/#{att3.id}")

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/attachments/#{att1.id}")
      api_get("/attachments/#{att2.id}")
      api_get("/attachments/#{att3.id}", {}, 404)

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first
      admin_user.save!

      api_get("/attachments/#{att1.id}", {}, 404)
      api_get("/attachments/#{att2.id}")
      api_get("/attachments/#{att3.id}")
    end

    it "index attachment with admin user active tags" do
      person1 = create(:full_person_tagging).person
      person2 = create(:empty_person)
      person3 = create(:alt_full_person_tagging).person

      issue1 = create(:basic_issue, person: person1)
      issue2 = create(:basic_issue, person: person2)
      issue3 = create(:basic_issue, person: person3)

      seed1 = create(:full_natural_docket_seed,
        issue: issue1, add_all_attachments: false)
      seed2 = create(:full_natural_docket_seed,
        issue: issue2, add_all_attachments: false)
      seed3 = create(:full_natural_docket_seed,
        issue: issue3, add_all_attachments: false)

      att1 = create(:jpg_attachment, thing: seed1)
      att2 = create(:jpg_attachment, thing: seed2)
      att3 = create(:jpg_attachment, thing: seed3)

      api_get("/attachments/")
      expect(api_response.meta.total_items).to eq(3)
      expect(api_response.data[0].id).to eq(att3.id.to_s)
      expect(api_response.data[1].id).to eq(att2.id.to_s)
      expect(api_response.data[2].id).to eq(att1.id.to_s)

      admin_user.tags << person1.tags.first
      admin_user.save!

      api_get("/attachments/")
      expect(api_response.meta.total_items).to eq(2)
      expect(api_response.data[0].id).to eq(att2.id.to_s)
      expect(api_response.data[1].id).to eq(att1.id.to_s)

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first
      admin_user.save!

      api_get("/attachments/")
      expect(api_response.meta.total_items).to eq(2)
      expect(api_response.data[0].id).to eq(att3.id.to_s)
      expect(api_response.data[1].id).to eq(att2.id.to_s)
    end
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
