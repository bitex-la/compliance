require 'rails_helper'
require 'helpers/api/issues_helper'

describe 'an admin user' do
  let(:admin_user) { create(:admin_user) }

  it 'Reviews and approves a user created via api' do
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
    page.current_path.should == "/issues/#{Issue.last.id}/edit"

    visit "/issues/#{Issue.last.id}"
    page.current_path.should == "/issues/#{Issue.last.id}/edit"

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
    select observation_reason.subject.truncate(140),
      from: "issue[observations_attributes][0][observation_reason_id]",
      visible: false
    select 'Client', from: 'issue[observations_attributes][0][scope]', visible: false
    fill_in 'issue[observations_attributes][0][note]',
      with: 'Please re-send your document'
    click_button 'Update Issue'    

    Observation.where(issue: issue).count.should == 1
    Issue.first.should be_observed

    # The issue goes away from the dashboard.
    click_link 'Dashboard'
  
    expect(page).to_not have_content(issue.id)

    get "/api/people/#{person.id}/issues/#{Issue.first.id}"

    issue_document = JSON.parse(response.body).deep_symbolize_keys

    # Customer re-submit his identification, via API
    issue_document[:included]
      .find{|x| x[:type] == 'identification_seeds' }
      .tap do |i|
        i[:attributes][:number] = '1234567890'
        i[:attributes][:issuer] = 'Colombia'
      end
    issue_document[:included]
      .find{|x| x[:type] == 'observations' }
      .tap do |i|
        i[:attributes] = {reply: "Va de vuelta el documento!!!"}
      end

    patch "/api/people/#{person.id}/issues/#{Issue.first.id}",
      params: JSON.dump(issue_document),
      headers: {"CONTENT_TYPE" => 'application/json' }
    assert_response 200

    Issue.first.should be_answered
    Observation.first.reply.should_not be_nil

    IdentificationSeed.first.tap do |seed|
      seed.reload
      seed.issuer.should == "Colombia"
      seed.number.should == "1234567890"
    end

    visit '/'

    within("#issue_#{issue.id} td.col.col-actions") do
      click_link('View')
    end

    page.should have_content 'Reject'
    page.should have_content 'Dismiss'

    click_link 'Approve'

    Issue.last.should be_approved
    Observation.last.should be_answered
    click_link 'Dashboard' 
    expect(page).to_not have_content(issue.id)

    visit "/issues/#{Issue.last.id}/edit"
    page.current_path.should == "/issues/#{Issue.last.id}"
  end

  it "Dismisses an issue that had only bogus data" do
    person = create :new_natural_person
    issue = person.issues.last
    login_as admin_user
    visit "/issues/#{issue.id}"
    click_link 'Dismiss'

    issue.reload.should be_dismissed
    person.reload.should_not be_enabled

    visit "/"
    expect(page).to_not have_content(issue.id)
  end

  it "Rejects an issue because an observation went unanswered" do
    person = create :new_natural_person, enabled: true
    person.should be_enabled
    issue = person.issues.last
    login_as admin_user
    visit "/issues/#{issue.id}"
    click_link 'Reject'

    issue.reload.should be_rejected
    person.reload.should_not be_enabled

    visit "/"
    expect(page).to_not have_content(issue.id)
  end

  it "Abandons an issue that was inactive" do
    pending
    fail
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

  it 'manually enables/disables and sets risk for a person' do
    pending
    fail
  end

  describe 'when running checks' do
    it 'runs it through a robot' do
      pending
      fail
    end

    it 'runs it manually' do
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
