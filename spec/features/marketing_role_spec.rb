require 'rails_helper'

describe 'a marketing role admin user' do
  let(:marketing_admin_user) { create(:marketing_admin_user) }

  it 'gets redirected trying to access to forbidden paths' do
    login_as marketing_admin_user

    %w(
      admin_users
      observation_reasons
      event_logs
      tags
      dashboards
    ).each do |path|
      visit "/#{path}"
      page.current_path.should == '/people'
      expect(page).to have_content 'You are not authorized to perform this action.'
    end
  end

  it 'cannot see restricted menu items' do
    login_as marketing_admin_user

    within '.header' do
      expect(page).to_not have_content 'Observation Reasons'
      expect(page).to_not have_content 'Admin Users'
      expect(page).to_not have_content 'Tags'
      expect(page).to_not have_content 'Event Logs'
      expect(page).to_not have_content 'Dashboard'
      expect(page).to_not have_content 'Observations'

      expect(page).to have_content 'People'
    end
  end

  it 'cannot create a person or view person' do
    person = create(:empty_person)
    issue = create(:basic_issue, person: person)
    login_as marketing_admin_user

    click_link 'People'
    expect(page).not_to have_content 'New Person'
    expect(page).not_to have_content 'View'
  end
end
