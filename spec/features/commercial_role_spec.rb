require 'rails_helper'

describe 'an commercial role admin user' do
  let(:commercial_admin_user) { create(:commercial_admin_user) }

  it 'gets redirected trying to access to forbidden paths' do
    login_as commercial_admin_user

    %w(
      admin_users
      observation_reasons
      event_logs
      tags
    ).each do |path|
      visit "/#{path}"
      page.current_path.should == '/dashboards'
      expect(page).to have_content 'You are not authorized to perform this action.'
    end
  end

  it 'cannot see restricted menu items' do
    login_as commercial_admin_user

    within '.header' do
      expect(page).to_not have_content 'Observation Reasons'
      expect(page).to_not have_content 'Admin Users'
      expect(page).to_not have_content 'Tags'
      expect(page).to_not have_content 'Event Logs'

      expect(page).to have_content 'Dashboard'
      expect(page).to have_content 'People'
      expect(page).to have_content 'Observations'
    end
  end

  it 'cannot create a person' do
    person = create(:empty_person)
    issue = create(:basic_issue, person: person)
    login_as commercial_admin_user

    click_link 'People'
    expect(page).not_to have_content 'New Person'

    within "tr[id='person_#{Person.first.id}'] td[class='col col-actions']" do
      click_link 'View'
    end

    expect(page).not_to have_content 'Edit Person'
    expect(page).not_to have_content 'Enable'
    expect(page).not_to have_content 'Disable'
    expect(page).not_to have_content 'Reject'

    click_link 'View Person Issues'
    expect(page).to have_content 'New'

    click_on 'Draft'
    within("tr[id='issue_#{issue.id}'] td[class='col col-id']") do
      click_link(issue.id)
    end

    expect(page).to have_content 'Edit'
    expect(page).not_to have_content 'Complete'
    expect(page).not_to have_content 'Approve'
    expect(page).not_to have_content 'Dismiss'
    expect(page).not_to have_content 'Abandon'
    expect(page).not_to have_content 'Reject'
  end
end
