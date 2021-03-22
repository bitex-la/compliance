require 'rails_helper'

describe 'people' do
  let(:compliance_admin_user) { create(:compliance_admin_user) }
  it 'download csv' do
    emails = [
      'jhon@doe.com', 'mike@test.com', 'frank@test.com', 'pete@test.com', 'mary@doe.com'
    ]
    5.times do |n|
      person = create(:empty_person)
      issue = create(:basic_issue, reason: IssueReason.new_client)
      create(:fixed_full_email_seed, address: emails[n], person: person, issue: issue)
      seed = create(:full_natural_docket_seed, person: person, issue: issue)
      seed.issue.answer!
    end

    login_as compliance_admin_user
    click_link 'People'
    expect(page).not_to have_content('Csv Pending Report')
    click_link 'Pending'
    expect(page).to have_content('Csv Pending Report')
    click_link 'Csv Pending Report'

    content = DownloadHelpers.download_content
    expect(content).to match(/jhon\@doe\.com.*\n.*mike\@test\.com.*\n.*frank\@test\.com/)
  end
end
