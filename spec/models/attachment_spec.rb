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
end
