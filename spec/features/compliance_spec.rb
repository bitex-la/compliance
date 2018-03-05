require 'rails_helper'
require 'helpers/api/issues_helper'

describe 'an admin user' do
  let(:admin_user) { create(:admin_user) }

  it 'Reviews a user created via api' do
    person = create :new_natural_person
    issue = person.issues.first

    observation_reason = create(:observation_reason)

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
    within("#issue_#{issue.id} td.col.col-actions") do
      click_link('View')
    end

    expect(page).to have_content 'Identification'
    expect(page).to have_content 'Domicile'
    expect(page).to have_content 'Natural Docket'
    expect(page).to have_content 'Allowance seed'

    # Admin verify the attachment(s)
    have_xpath("//li[@class='has_many_container attachments']", count: 4)
    within first "li.has_many_container.attachments" do
      within first "fieldset.inputs.has_many_fields" do
       click_link 'Show'
      end
    end
   
    window = page.driver.browser.window_handles
    page.driver.browser.switch_to.window(window.first)

    # Admin sends an observation to customer about their identification (it was blurry)
    click_link 'Add New Observation' 
    select observation_reason.subject.truncate(140), from: "issue[observations_attributes][0][observation_reason_id]", visible: false
    select 'Client', from: 'issue[observations_attributes][0][scope]', visible: false
    fill_in 'issue[observations_attributes][0][note]', with: 'Please re-send your document'
    click_button 'Update Issue'    

    Observation.where(issue: issue).count.should == 1
    Issue.first.observed?.should be_truthy

    # The issue goes away from the dashboard.
    click_link 'Dashboard'
  
    expect(page).to_not have_content(issue.id)

    get "/api/people/#{person.id}/issues/#{Issue.first.id}"

    issue_document = JSON.parse(response.body).deep_symbolize_keys

    # Customer re-submit his identification, via API
    issue_document[:included][4][:attributes][:number] = '1234567890'
    issue_document[:included][4][:attributes][:issuer] = 'Colombia'
    issue_document[:included][7][:attributes] = {reply: "Va de vuelta el documento!!!"}

    patch "/api/people/#{person.id}/issues/#{Issue.first.id}",
      params: JSON.dump(issue_document),
      headers: {"CONTENT_TYPE" => 'application/json' }
    assert_response 200

    Issue.first.replicated?.should be_truthy 
    Observation.first.reply.should_not be_nil

    IdentificationSeed.first.tap do |seed|
      seed.reload
      seed.issuer.should == "Colombia"
      seed.number.should == "1234567890"
    end

    # Admin accepts the customer data, the issue goes away from the to-do list | Admin dismisses the issue, the person is rejected
    # Worldcheck is run on the customer, customer is accepted when there are no hits, issue is closed. | Customer had hits, admin needs to check manually.
  end

  describe 'when admin edits an issue' do
    it 'can edit the domicile' do
      post api_person_issues_path(create(:full_natural_person).id),
        params: Api::IssuesHelper.issue_with_domicile_seed(:png)
      login_as admin_user

      issue = Issue.last
      within("tr[id='issue_#{issue.id}'] td[class='col col-actions']") do
        click_link('View')
      end
      pending
      fail
    end

    it 'can edit allowances' do
      pending
      fail
    end
  end

  it 'keeps track of usage allowances' do
    pending
    fail
    # A funding event is received via API that overruns the customer allowance
    # A allowance issue is created,
    # An admin reviews the issue, decides to require more information, the person is now 'invalid' | An admin dismisses the issue, customer remains valid
    # The customer sends further data (via API) (along with a comment)
    # An admin reviews the data and decides it's not enough. (and places further comments)
    # The customer finally attaches all the required documents
    # The admin accepts the documents, assigns a value and periodicity to the new allowances backed by the documents. 
  end

  it 'lets admins run blacklist checks manually' do
    pending
    fail
  end

  it 'lets clients run blacklist checks via api' do
    pending
    fail
  end

  it 'registers associated accounts and bitcoin addresses' do
    pending
    fail
  end

  it 'performs periodic checks using third party databases' do
    pending
    fail
  end

  it 'exports the customer data signed by bitex' do
    pending
    fail
  end
end
