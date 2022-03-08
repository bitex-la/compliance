require 'rails_helper'

describe Attachment do
  it_behaves_like 'person_scopable',
    create: -> (person_id) {
      fruit = with_untagged_admin do
        issue = create(:basic_issue, person_id: person_id)
        seed = create(:full_natural_docket_seed, issue: issue, add_all_attachments: false)
        issue.approve!
        seed.reload.fruit
      end
      create(:jpg_attachment, thing: fruit)
    },
    change_person: -> (obj, person_id){
      fruit = with_untagged_admin do
        issue = create(:basic_issue, person_id: person_id)
        seed = create(:full_natural_docket_seed, issue: issue, add_all_attachments: false)
        issue.approve!
        seed.reload.fruit
      end
      obj.attached_to_fruit = fruit
    }

  it_behaves_like 'person_scopable',
    create: -> (person_id) {
      seed = with_untagged_admin do
        issue = create(:basic_issue, person_id: person_id)
        create(:full_natural_docket_seed, issue: issue, add_all_attachments: false)
      end
      create(:jpg_attachment, thing: seed)
    },
    change_person: -> (obj, person_id){
      seed = with_untagged_admin do
        issue = create(:basic_issue, person_id: person_id)
        create(:full_natural_docket_seed, issue: issue, add_all_attachments: false)
      end
      obj.attached_to_seed = seed
    }

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

  it 'can create a new seed with an attachments' do
    person = create(:empty_person)
    issue = Issue.new(person: person)
    domicile_seed = issue.domicile_seeds.build(country: "AR")
    domicile_seed.attachments.build(attributes_for(:attachment))

    issue.should be_valid
    issue.save
    assert_logging(issue, :create_entity, 1)
  end

  it 'is invalid when attachment is bigger than 10 MB' do
    phone = create(:full_natural_person).reload.phones.first
    a = build(:exceeding_size_attachment, thing: phone)
    expect(a.attached_to_fruit).to eq phone
    a.should_not be_valid
    expect(a.errors[:document_file_size]).to eq ['File exceeding_size.doc size must be lower than 10MB.']
  end

  it 'allows old exceeding size attachments' do
    expect(create(:exceeding_size_attachment)).not_to be_valid
    expect(build(:exceeding_size_attachment)).not_to be_valid
    expect(build(:exceeding_size_attachment, created_at: Date.new(2021, 12, 1), updated_at: Date.new(2021, 12, 16))).not_to be_valid
    expect(build(:exceeding_size_attachment, created_at: Date.new(2021, 12, 15))).not_to be_valid
    expect(build(:exceeding_size_attachment, created_at: Date.new(2021, 12, 16))).not_to be_valid

    expect(build(:exceeding_size_attachment, created_at: Date.new(2021, 12, 1))).to be_valid
  end
end
