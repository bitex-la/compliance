require 'rails_helper'

describe 'Dashboard' do
  it 'differentiates issues with priority bigger than zero' do
    login_as create(:admin_user)

    3.times do |n|
      create(:basic_issue, priority: n + 1)
    end

    4.times do
      create(:basic_issue)
    end

    visit '/'
    click_link 'All'

    expect(page).to have_selector(:css, '.top-priority', count: 3)

    indexes = Array.new(7) do |i|
      page.body.index("id=\"issue_#{i + 1}\"")
    end

    expect(indexes.sort).to eq([indexes[2],
      indexes[1],
      indexes[0],
      indexes[6],
      indexes[5],
      indexes[4],
      indexes[3]])
  end
end
