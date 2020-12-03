# frozen_string_literal: true

require 'rails_helper'

describe 'an admin restricted role' do
  let(:business_admin_user) { create(:business_admin_user) }

  it 'successfully access' do
    login_as business_admin_user

    %w[
      dashboards
      observation_reasons
      observations
      tags
      attachments
      fund_deposits
      people
      admin_comments
    ].each do |path|
      visit "/#{path}"
      expect(page.current_path).to eq("/#{path}")
    end
  end

  it 'cannot see event logs' do
    login_as business_admin_user

    visit '/event_logs'

    expect(page.current_path).to eq('/dashboards')
    expect(page).to(
      have_content('You are not authorized to perform this action.')
    )
  end

  it 'cannot see admin users' do
    login_as business_admin_user

    visit '/admin_users'

    expect(page.current_path).to eq('/dashboards')
    expect(page).to(
      have_content('You are not authorized to perform this action.')
    )
  end

  it 'cannot create admin users' do
    login_as business_admin_user

    visit '/admin_users'
    expect(page).to_not have_content('New Admin User')
  end

  it 'cannot update admin users' do
    admin_user = create(:admin_user)
    login_as business_admin_user

    visit "/admin_users/#{admin_user.id}/edit"

    expect(page).to(
      have_content('You are not authorized to perform this action.')
    )
    expect(page.current_path).to eq('/dashboards')
  end
end
