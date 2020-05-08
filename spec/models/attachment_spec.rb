require 'rails_helper'

describe Attachment do
  it_behaves_like 'person_scopable',
    create: -> (person_id) {
      issue = create(:basic_issue, person_id: person_id)
      seed = create(:full_natural_docket_seed, issue: issue, add_all_attachments: false)
      issue.approve!
      fruit = seed.reload.fruit
      create(:jpg_attachment, thing: fruit)
    },
    change_person: -> (obj, person_id){
      issue = create(:basic_issue, person_id: person_id)
      seed = create(:full_natural_docket_seed, issue: issue, add_all_attachments: false)
      issue.approve!
      obj.attached_to_fruit = seed.reload.fruit
    }

  it_behaves_like 'person_scopable',
    create: -> (person_id) {
      issue = create(:basic_issue, person_id: person_id)
      seed = create(:full_natural_docket_seed, issue: issue, add_all_attachments: false)
      Attachment.create!(attached_to_seed: seed)
    },
    change_person: -> (obj, person_id){ obj.person_id = person_id }

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
      admin_user
    end

    def assert_accessible(*args)
      args.each { |i| expect(Attachment.find(i.id)).to_not be_nil }
    end

    def assert_not_accessible(*args)
      args.each { |i| expect { Attachment.find(i.id) }.to raise_error(ActiveRecord::RecordNotFound) }
    end

    def setup_for_admin_tags_spec
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

      [att1, att2, att3, att4]
    end

    it "show attachment with admin user active tags" do
      att1, att2, att3, att4 = setup_for_admin_tags_spec
      person1 = att1.person
      person3 = att3.person

      assert_accessible(att1, att2, att3, att4)

      admin_user.tags << person1.tags.first
      assert_accessible(att1, att2, att4)
      assert_not_accessible(att3)

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first

      assert_accessible(att2, att3, att4)
      assert_not_accessible(att1)

      admin_user.tags << person1.tags.first
      assert_accessible(att1, att2, att3, att4)
    end

    it "index attachment with admin user active tags" do
      att1, att2, att3, att4 = setup_for_admin_tags_spec
      person1 = att1.person
      person3 = att3.person

      expect(Attachment.all).to contain_exactly(att1, att2, att3, att4)

      admin_user.tags << person1.tags.first
      expect(Attachment.all).to contain_exactly(att1, att2, att4)

      admin_user.tags.delete(person1.tags.first)
      admin_user.tags << person3.tags.first
      expect(Attachment.all).to contain_exactly(att2, att3, att4)

      admin_user.tags << person1.tags.first
      expect(Attachment.all).to contain_exactly(att1, att2, att3, att4)
    end
  end
end
