require 'rails_helper'
require 'helpers/api/v1/issues_helper'

describe '' do
  let(:admin_user) { create(:admin_user) }

  it 'creates a new natural person' do
    # Creates issue via API: Includes seeds for domicile, identification, docket, quota.
    attachment = Base64.encode64(file_fixture('simple.png').read)
    issue  = Api::V1::IssuesHelper.issue_with_domicile_seed(
      attachment, 
      'image/png',
      'file.png'
    )

    post api_v1_issues_path, params: issue

    issue = Issue.first
    expect(Issue.count).to be_equal 1
    expect(Person.count).to be_equal 1
    expect(DomicileSeed.count).to be_equal 1
    expect(DomicileSeed.where(issue: issue).count).to be_equal 1
    expect(DomicileSeed.first.attachments.count).to be_equal 1
    assert_response 201

    # Admin does not see it as pending
    visit admin_user_session_path
    fill_in 'admin_user[email]', with: admin_user.email
    fill_in 'admin_user[password]', with: admin_user.password
    click_button 'Login'

    expect(page).to have_content 'Signed in successfully.'

    # Admin sees issue in dashboard.
    expect(page).to have_content issue.id
    within("//tr[@id='issue_#{issue.id}']") do
      click_link('View')
    end

    expect(page).to have_content 'Issue Details'

    

    # Admin sends comments to customer about their identification (it was blurry)
       # The issue goes away from the dashboard.
    # Customer re-submits identification (we get it via API)
    # Admin accepts the customer data, the issue goes away from the to-do list | Admin dismisses the issue, the person is rejected
    # Worldcheck is run on the customer, customer is accepted when there are no hits, issue is closed. | Customer had hits, admin needs to check manually.
  end

  it 'keeps track of usage quotas' do
    # A funding event is received via API that overruns the customer quota
    # A quota issue is created,
    # An admin reviews the issue, decides to require more information, the person is now 'invalid' | An admin dismisses the issue, customer remains valid
    # The customer sends further data (via API) (along with a comment)
    # An admin reviews the data and decides it's not enough. (and places further comments)
    # The customer finally attaches all the required documents
    # The admin accepts the documents, assigns a value and periodicity to the new quotas backed by the documents. 
  end

  it 'registers associated accounts and bitcoin addresses' do
  end

  it 'performs periodic checks using third party databases' do
  end

  it 'exports the customer data signed by bitex' do
  end
end