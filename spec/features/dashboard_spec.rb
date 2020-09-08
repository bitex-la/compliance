require 'rails_helper'

describe 'Dashboard' do
  def create_issue(first_name, last_name, priority)
    issue=create(:basic_issue, priority: priority, person: create(:empty_person))
    create(:natural_docket, first_name: first_name, last_name: last_name, person: issue.person)
    issue.approve!
  end

  it 'differentiates issues with priority bigger than zero' do
    login_as create(:admin_user)

    create_issue('Pedro', 'Perez', 0)
    create_issue('María', 'Mendez', 1)
    create_issue('Ricardo', 'Tapia', 0)
    create_issue('Bruno', 'Diaz', 2)
    create_issue('Miguel', 'Rodriguez', 1)
    create_issue('Andrés', 'Andrada', 3)

    visit '/'
    click_link 'All'
    expect(page).to have_selector(:css, '.top-priority', count: 4)
    expect(page).to have_selector(:css, '.zero-priority', count: 2)

    expect(page.text.index('Andrés Andrada')).to be < page.text.index('Bruno Diaz')
    expect(page.text.index('Bruno Diaz')).to be < page.text.index('María Mendez')
    expect(page.text.index('María Mendez')).to be < page.text.index('Miguel Rodriguez')
    expect(page.text.index('Miguel Rodriguez')).to be < page.text.index('Pedro Perez')
    expect(page.text.index('Pedro Perez')).to be < page.text.index('Ricardo Tapia')
  end
end
