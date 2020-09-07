require 'rails_helper'

describe 'Dashboard' do
  it 'differentiates issues with priority bigger than zero' do
    login_as create(:admin_user)

    5.times do |n|
      create(:basic_issue, priority: n + 3)
    end

    6.times do
      create(:basic_issue)
    end

    visit '/'
    click_link 'All'
    expect(page).to have_selector(:css, '.top-priority', count: 5)
    expect(page).to have_selector(:css, '.zero-priority', count: 6)
    expect(page.text).to match(/7.+\n6.+\n5.+\n4.+\n3.+\n0.+\n0.+\n0.+\n0.+\n0.+\n0.+/)
  end
end
