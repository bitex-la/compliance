require 'rails_helper'

describe 'Dashboard' do
  it 'differentiates issues with priority bigger than zero' do
    login_as create(:admin_user)

    2.times do
      create(:basic_issue)
    end

    4.times do |n|
      create(:basic_issue, priority: n + 1)
    end

    visit '/'
    click_link 'All'

    expect(page).to have_selector(:css, '.top-priority', count: 4)
    expect(page).to have_selector(:css, '.zero-priority', count: 2)

    id1 = page.body.index('id="issue_1"')
    id2 = page.body.index('id="issue_2"')
    id3 = page.body.index('id="issue_3"')
    id4 = page.body.index('id="issue_4"')
    id5 = page.body.index('id="issue_5"')
    id6 = page.body.index('id="issue_6"')

    expect(id6).to be < id5
    expect(id5).to be < id4
    expect(id4).to be < id3
    expect(id3).to be < id1
    expect(id1).to be < id2
  end
end
