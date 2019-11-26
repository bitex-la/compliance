require 'rails_helper'

describe 'an admin user' do
  let(:admin_user) { create(:admin_user) }

  it 'download user KYC files' do
    person = create :full_natural_person

    person.should be_enabled

    login_as admin_user
    click_link('People')
    click_link('All')

    within("#person_#{person.id} td.col.col-actions") do
      click_link('View')
    end
    page.current_path.should == "/people/#{person.id}"
    open_download_profile_actions_menu('Basic')
  end
end