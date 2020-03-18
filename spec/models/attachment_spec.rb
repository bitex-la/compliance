require 'rails_helper'

RSpec.describe Attachment, type: :model do
  it 'is valid when attached to something' do
    phone = create(:full_natural_person).reload.phones.first
    a = build(:attachment, thing: phone)
    a.attached_to_fruit.should == phone
    a.should be_valid
  end

  it 'is invalid when not attached to anything' do
    a = build(:attachment)
    a.attached_to.should be_nil
    a.should_not be_valid
    a.errors[:base].should == ['must_be_attached_to_something']
  end

  it 'can creat a new seed with an attachments' do
    person = create(:empty_person)
    issue = Issue.new(person: person)
    domicile_seed = issue.domicile_seeds.build(country: "AR")
    domicile_seed.attachments.build(attributes_for(:attachment))

    issue.should be_valid
    issue.save
    assert_logging(issue, :create_entity, 1)
  end

  describe "When filter by admin tags" do
    let(:admin_user) { AdminUser.current_admin_user = create(:admin_user) }

    before :each do
      admin_user.tags.clear
      admin_user.save!
    end

    it "allow attachment creation only with person valid admin tags" do
      person1 = create(:full_person_tagging).person
      person2 = create(:alt_full_person_tagging).person

      issue1 = create(:basic_issue, person: person1)
      issue2 = create(:basic_issue, person: person2)

      seed1 = create(:full_natural_docket_seed,
        issue: issue1, add_all_attachments: false)
      seed2 = create(:full_natural_docket_seed,
        issue: issue2, add_all_attachments: false)

      admin_user.tags << person1.tags.first
      admin_user.save!

      expect do
        attachment = Attachment.new(attached_to_seed: NaturalDocketSeed.find(seed1.id))
        attachment.save!
      end.to change { Attachment.count }.by(1)

      expect { NaturalDocketSeed.find(seed2.id) }.to raise_error(ActiveRecord::RecordNotFound)

      admin_user.tags << person2.tags.first
      admin_user.save!

      expect do
        attachment = Attachment.new(attached_to_seed: NaturalDocketSeed.find(seed1.id))
        attachment.save!
      end.to change { Attachment.count }.by(1)

      expect do
        attachment = Attachment.new(attached_to_seed: NaturalDocketSeed.find(seed2.id))
        attachment.save!
      end.to change { Attachment.count }.by(1)
    end

    it "allow attachment creation with person tags if admin has no tags" do
      person = create(:full_person_tagging).person
      issue = create(:basic_issue, person: person)
      seed = create(:full_natural_docket_seed,
        issue: issue, add_all_attachments: false)

      expect do
        attachment = Attachment.new(attached_to_seed: NaturalDocketSeed.find(seed.id))
        attachment.save!
      end.to change { Attachment.count }.by(1)
    end

    it "allow attachment creation without person tags if admin has no tags" do
      person = create(:empty_person)

      issue = create(:basic_issue, person: person)
      seed = create(:full_natural_docket_seed,
        issue: issue, add_all_attachments: false)

      expect do
        attachment = Attachment.new(attached_to_seed: NaturalDocketSeed.find(seed.id))
        attachment.save!
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
        attachment = Attachment.new(attached_to_seed: NaturalDocketSeed.find(seed.id))
        attachment.save!
      end.to change { Attachment.count }.by(1)
    end

    it "show attachment with admin user active tags" do
      person1 = create(:full_person_tagging).person
      person2 = create(:empty_person)
      person3 = create(:alt_full_person_tagging).person
      person4 = create(:empty_person)
      person4.tags << person1.tags.first
      person4.tags << person3.tags.first

      issue1 = create(:basic_issue, person: person1)
      issue2 = create(:basic_issue, person: person2)
      issue3 = create(:basic_issue, person: person3)
      issue4 = create(:basic_issue, person: person4)

      seed1 = create(:full_natural_docket_seed,
        issue: issue1, add_all_attachments: false)
      seed2 = create(:full_natural_docket_seed,
        issue: issue2, add_all_attachments: false)
      seed3 = create(:full_natural_docket_seed,
        issue: issue3, add_all_attachments: false)
      seed4 = create(:full_natural_docket_seed,
        issue: issue4, add_all_attachments: false)

      att1 = create(:jpg_attachment, thing: seed1)
      att2 = create(:jpg_attachment, thing: seed2)
      att3 = create(:jpg_attachment, thing: seed3)
      att4 = create(:jpg_attachment, thing: seed4)

      Attachment.find(att1.id)
      Attachment.find(att2.id)
      Attachment.find(att3.id)
      Attachment.find(att4.id)

      admin_user.tags << person1.tags.first
      admin_user.save!

      Attachment.find(att1.id)
      Attachment.find(att2.id)
      expect { Attachment.find(att3.id) }.to raise_error(ActiveRecord::RecordNotFound)
      Attachment.find(att4.id)

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first
      admin_user.save!

      expect { Attachment.find(att1.id) }.to raise_error(ActiveRecord::RecordNotFound)
      Attachment.find(att2.id)
      Attachment.find(att3.id)
      Attachment.find(att4.id)

      admin_user.tags << person1.tags.first
      admin_user.save!

      Attachment.find(att1.id)
      Attachment.find(att2.id)
      Attachment.find(att3.id)
      Attachment.find(att4.id)
    end

    it "index attachment with admin user active tags" do
      person1 = create(:full_person_tagging).person
      person2 = create(:empty_person)
      person3 = create(:alt_full_person_tagging).person
      person4 = create(:empty_person)
      person4.tags << person1.tags.first
      person4.tags << person3.tags.first

      issue1 = create(:basic_issue, person: person1)
      issue2 = create(:basic_issue, person: person2)
      issue3 = create(:basic_issue, person: person3)
      issue4 = create(:basic_issue, person: person4)

      seed1 = create(:full_natural_docket_seed,
        issue: issue1, add_all_attachments: false)
      seed2 = create(:full_natural_docket_seed,
        issue: issue2, add_all_attachments: false)
      seed3 = create(:full_natural_docket_seed,
        issue: issue3, add_all_attachments: false)
      seed4 = create(:full_natural_docket_seed,
        issue: issue4, add_all_attachments: false)

      att1 = create(:jpg_attachment, thing: seed1)
      att2 = create(:jpg_attachment, thing: seed2)
      att3 = create(:jpg_attachment, thing: seed3)
      att4 = create(:jpg_attachment, thing: seed4)

      attachments = Attachment.all
      expect(attachments.count).to eq(4)
      expect(attachments[0].id).to eq(att1.id)
      expect(attachments[1].id).to eq(att2.id)
      expect(attachments[2].id).to eq(att3.id)
      expect(attachments[3].id).to eq(att4.id)

      admin_user.tags << person1.tags.first
      admin_user.save!

      attachments = Attachment.all
      expect(attachments.count).to eq(3)
      expect(attachments[0].id).to eq(att1.id)
      expect(attachments[1].id).to eq(att2.id)
      expect(attachments[2].id).to eq(att4.id)

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first
      admin_user.save!

      attachments = Attachment.all
      expect(attachments.count).to eq(3)
      expect(attachments[0].id).to eq(att2.id)
      expect(attachments[1].id).to eq(att3.id)
      expect(attachments[2].id).to eq(att4.id)

      admin_user.tags << person1.tags.first
      admin_user.save!

      attachments = Attachment.all
      expect(attachments.count).to eq(4)
      expect(attachments[0].id).to eq(att1.id)
      expect(attachments[1].id).to eq(att2.id)
      expect(attachments[2].id).to eq(att3.id)
      expect(attachments[3].id).to eq(att4.id)
    end
  end
end
