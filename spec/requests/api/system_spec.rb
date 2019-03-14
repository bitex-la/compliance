require 'rails_helper'

describe System do
  it 'truncates the database, keeping admins' do
    create :full_natural_person
    create :new_natural_person
    admin_user = create(:admin_user)

    AdminUser.count.should == 1
    Person.count.should == 5
    Issue.count.should == 4

    post "/api/system/truncate",
      headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

    AdminUser.count.should == 1
    Person.count.should == 0
    Issue.count.should == 0
  end

  it 'cannot truncate in prod' do
    Rails.stub(env: ActiveSupport::StringInquirer.new("production"))

    create :full_natural_person
    create :new_natural_person
    admin_user = create(:admin_user)

    AdminUser.count.should == 1
    Person.count.should == 5
    Issue.count.should == 4

    post "/api/system/truncate",
      headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

    AdminUser.count.should == 1
    Person.count.should == 5
    Issue.count.should == 4

    Rails.unstub(:env)
  end
end
