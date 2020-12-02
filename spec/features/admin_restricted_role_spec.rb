# frozen_string_literal: true

require 'rails_helper'

describe 'an admin restricted role' do
  let(:admin_restricted_user) { create(:admin_restricted_user) }

  it 'successfully access' do
    login_as admin_restricted_user

    %w[
      dashboards
      admin_users
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
    login_as admin_restricted_user

    visit '/event_logs'

    expect(page.current_path).to eq('/dashboards')
    expect(page).to(
      have_content('You are not authorized to perform this action.')
    )
  end
end
