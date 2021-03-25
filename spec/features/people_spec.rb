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
    end

    login_as compliance_admin_user
    click_link 'People'
    click_link 'Pending'
    click_link 'CSV'

    content = DownloadHelpers.download_content
    expect(content).to match(/mary\@doe\.com.*\n.*pete\@test\.com.*\n.*frank\@test\.com.*\n.*mike\@test\.com.*\n.*jhon\@doe\.com/)
    expect(content).to match(/Mary,Doe.*\n.*Peter,Clark.*\n.*Frank,Constanza.*\n.*Mike,Jhonson.*\n.*Jhon,Doe/)
  end
end
