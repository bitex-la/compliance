require 'rails_helper'

describe 'an operations role admin user' do
  let(:operations_admin_user) { create(:operations_admin_user) }

  it 'gets redirected trying to access to forbidden paths' do
    login_as operations_admin_user

    %w(
      admin_users
      observation_reasons
      observations
      event_logs
      tags
    ).each do |path|
      visit "/#{path}"
      page.current_path.should == '/dashboards'
      expect(page).to have_content 'You are not authorized to perform this action.'
    end
  end

  it 'cannot see restricted menu items' do
    login_as operations_admin_user

    within '.header' do
      expect(page).to_not have_content 'Observation Reasons'
      expect(page).to_not have_content 'Admin Users'
      expect(page).to_not have_content 'Observations'
      expect(page).to_not have_content 'Tags'
      expect(page).to_not have_content 'Event Logs'

      expect(page).to have_content 'Dashboard'
      expect(page).to have_content 'People'
    end
  end

  it 'can create a natural person and it issue' do
    observation_reason = create(:human_world_check_reason)
    login_as operations_admin_user

    click_link 'People'
    click_link 'New Person'
    click_button 'Create Person'

    visit '/'
    click_link 'People'
    within "tr[id='person_#{Person.first.id}'] td[class='col col-actions']" do
      click_link 'View'
    end

    expect(page).not_to have_content 'Edit Person'
    expect(page).not_to have_content 'Enable'
    expect(page).not_to have_content 'Disable'
    expect(page).not_to have_content 'Reject'

    click_link 'View Person Issues'
    click_link 'New'

    fulfil_new_issue_form

    click_button "Create Issue"
    click_link "Edit"

    add_observation(observation_reason, 'Please check this guy on world check')

    click_button "Update Issue"
    click_link "Edit"

    expect(page).not_to have_content 'Approve'
    expect(page).not_to have_content 'Dismiss'
    expect(page).not_to have_content 'Abandon'
    expect(page).not_to have_content 'Reject'
  end

  it 'can edit an issue' do
    person = create(:full_natural_person).reload
    issue = create(:full_natural_person_issue, person: person)

    login_as operations_admin_user

    click_on 'Draft'
    within("tr[id='issue_#{issue.id}'] td[class='col col-id']") do
      click_link(issue.id)
    end

    click_link "Edit"

    find('li[title="Natural dockets"] a').click

    fill_seed('natural_docket', {
      first_name: 'Joe',
      last_name: 'Jameson',
      birth_date: "1975-01-15"
    }, false)

    find('li[title="Domiciles"] a').click

    select_with_search(
      '#issue_domicile_seeds_attributes_0_replaces_input',
      Domicile.first.name
    )

    within ".has_many_container.domicile_seeds" do
      fill_seed('domicile', {
        country: 'AR',
        state: 'Buenos Aires',
        city: 'C.A.B.A',
        street_address: 'Triunvirato',
        street_number: '2300',
        postal_code: '1254',
        floor: '',
        apartment: ''
      })
    end

    click_button "Update Issue"

    within(".action_items") do
      expect(page).not_to have_selector(:link_or_button, 'Approve')
      expect(page).not_to have_selector(:link_or_button, 'Dismiss')
      expect(page).not_to have_selector(:link_or_button, 'Abandon')
      expect(page).not_to have_selector(:link_or_button, 'Reject')
    end

    click_link "Edit"

    find('li[title="Domiciles"] a').click

    accept_alert do
      click_link 'Remove'
    end

    Capybara.using_wait_time(15) do
      expect(page).to have_content('Domicile seed was successfully destroyed.')
    end
  end
end
