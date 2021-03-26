require 'rails_helper'

describe 'people' do
  let(:compliance_admin_user) { create(:compliance_admin_user) }

  it 'download csv' do
    data = [
      {
        email: 'jhon@doe.com',
        first_name: 'Jhon',
        last_name: 'Doe'
      },
      {
        email: 'mike@test.com',
        first_name: 'Mike',
        last_name: 'Jhonson'
      },
      {
        email: 'frank@test.com',
        first_name: 'Frank',
        last_name: 'Constanza'
      },
      {
        email: 'pete@test.com',
        first_name: 'Peter',
        last_name: 'Clark'
      },
      {
        email: 'mary@doe.com',
        first_name: 'Mary',
        last_name: 'Doe'
      }
    ]
    5.times do |n|
      person = create(:empty_person)
      issue = create(:basic_issue, reason: IssueReason.new_client)
      create(:fixed_full_email_seed, address: data[n][:email], person: person, issue: issue)
      seed = create(:full_natural_docket_seed,
                    person: person,
                    issue: issue,
                    first_name: data[n][:first_name],
                    last_name: data[n][:last_name])
      seed.issue.answer!
      seed.issue.approve! if n == 4
    end

    login_as compliance_admin_user
    click_link 'People'
    click_link 'Pending'
    click_link 'CSV'

    content = DownloadHelpers.download_content
    expect(content).to match(/pete\@test\.com.*\n.*frank\@test\.com.*\n.*mike\@test\.com.*\n.*jhon\@doe\.com/)
    expect(content).to match(/Peter,Clark.*\n.*Frank,Constanza.*\n.*Mike,Jhonson.*\n.*Jhon,Doe/)
    expect(content).to have_content('*', count: 4)
  end

  it 'shows pending people' do
    person = create(:empty_person)
    seed = create(:full_natural_docket_seed,
                  person: person,
                  issue: create(:basic_issue, reason: IssueReason.new_client),
                  first_name: 'Peter')
    seed.issue.complete!

    person2 = create(:empty_person)
    seed = create(:full_natural_docket_seed,
                  person: person2,
                  issue: create(:basic_issue, reason: IssueReason.new_client),
                  first_name: 'Jhon')
    seed.issue.observe!

    person3 = create(:empty_person)
    seed = create(:full_natural_docket_seed,
                  person: person3,
                  issue: create(:basic_issue, reason: IssueReason.new_client),
                  first_name: 'Gabriel')
    seed.issue.answer!

    20.times do
      person = create(:empty_person)
      create(:basic_issue, person: person)
    end

    login_as compliance_admin_user
    click_link 'People'
    click_link 'Pending'
    expect(page).to have_content('Peter')
    expect(page).to have_content('Jhon')
    expect(page).to have_content('Gabriel')
    expect(page).to have_content('Displaying all 3 People')
  end
end
