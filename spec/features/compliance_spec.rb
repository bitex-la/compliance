require 'rails_helper'
require 'helpers/api/issues_helper'

describe 'an admin user' do
  let(:admin_user) { create(:admin_user) }

  it 'Reviews a user created via api' do
    person = create :new_natural_person
    issue = person.issues.first

    Issue.count.should == 1
    Person.count.should == 1 
    DomicileSeed.count.should == 1
    IdentificationSeed.count.should == 1
    NaturalDocketSeed.count.should == 1
    AllowanceSeed.count.should == 2

    # Admin does not see it as pending
    login_as admin_user

    expect(page).to have_content 'Signed in successfully.'

    # Admin sees issue in dashboard.
    expect(page).to have_content issue.id

     # Admin clicks in the issue to see the detail
    within("//tr[@id='issue_#{issue.id}']//td[@class='col col-actions']") do
      click_link('View')
    end

    expect(page).to have_content 'Identification'
    expect(page).to have_content 'Domicile'
    expect(page).to have_content 'Natural Docket'
    expect(page).to have_content 'Allowance seed'

    # Admin verify the attachment(s)
    have_xpath("//li[@class='has_many_container attachments']", count: 4)
    within first("//li[@class='has_many_container attachments']") do
      within first("/fieldset[@class='inputs has_many_fields']") do
       click_link 'Show'
      end
    end

    expect(page).to have_content 'Attachment Details'
    expect(page).to have_content IdentificationSeed.first.attachments.first.document_file_name
    
    click_link "Issue #{issue.id}"
   


    # within("//tr[@id='domicile_seed_#{domicile_seed.id}']") do
    #  expect(page).to have_content domicile_seed.attachments.first.document_file_name
    #end
    
    # Admin sends comments to customer about their identification (it was blurry)
    #click_link('Add comment')
    #expect(page).to have_content 'Post new comment'

    #fill_in 'comment[title]', with: 'Domicile document is blurry'
    #fill_in 'comment[body]',  with: 'Please re-send your document' 
    #click_button 'Create Comment'

    #expect(issue.reload.comments.count).to be_equal 1
    #within("//tr[@class='row row-commentable']") do
    #  click_link("Issue ##{issue.id}")
    #end

       # The issue goes away from the dashboard.
    # Customer re-submits identification (we get it via API)
    # Admin accepts the customer data, the issue goes away from the to-do list | Admin dismisses the issue, the person is rejected
    # Worldcheck is run on the customer, customer is accepted when there are no hits, issue is closed. | Customer had hits, admin needs to check manually.
  end

  describe 'when admin edits an issue' do
    it 'can edit the domicile' do
      post api_issues_path, params: Api::IssuesHelper.issue_with_domicile_seed(
        Base64.encode64(file_fixture('simple.png').read),
        'image/png',
        'file.png'
      )
      login_as admin_user
      issue = Issue.first

      print page.body
      within("//tr[@id='issue_#{issue.id}']//td[@class='col col-actions']") do
        click_link('Edit')
      end
    end

    it 'can edit allowances' do
    end
  end

  it 'keeps track of usage allowances' do
    # A funding event is received via API that overruns the customer allowance
    # A allowance issue is created,
    # An admin reviews the issue, decides to require more information, the person is now 'invalid' | An admin dismisses the issue, customer remains valid
    # The customer sends further data (via API) (along with a comment)
    # An admin reviews the data and decides it's not enough. (and places further comments)
    # The customer finally attaches all the required documents
    # The admin accepts the documents, assigns a value and periodicity to the new allowances backed by the documents. 
  end

  it 'registers associated accounts and bitcoin addresses' do
  end

  it 'performs periodic checks using third party databases' do
  end

  it 'exports the customer data signed by bitex' do
  end
end
