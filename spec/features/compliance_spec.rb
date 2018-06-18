require 'rails_helper'
require 'helpers/api/issues_helper'

describe 'an admin user' do
  let(:admin_user) { create(:admin_user) }

  def fill_seed(kind, attributes, has_many = true, index = 0)
    attributes.each do |key, value|
      if has_many
      	fill_in "issue[#{kind}_seeds_attributes][#{index}][#{key}]",
	  with: value
      else
        fill_in "issue[#{kind}_seed_attributes][#{key}]",
	  with: value
      end
    end
  end

  def fill_attachment(kind, ext = 'jpg', has_many = true, index = 0, att_index = 0)
    wait_for_ajax
    path = if has_many
      "issue[#{kind}_attributes][#{index}][attachments_attributes][#{att_index}][document]"
    else
      "issue[#{kind}_attributes][attachments_attributes][#{att_index}][document]"
    end
    attach_file(path,
        File.absolute_path("./spec/fixtures/files/simple.#{ext}"), wait: 10.seconds)
  end

  #def assert_logging(entity, verb, expected_count)
  #  EventLog.where(entity: entity, verb: verb).count.should == expected_count
  #end

  it 'creates a new natural person and its issue via admin' do
    observation_reason = create(:human_world_check_reason)
    login_as admin_user

    click_link 'People'
    click_link 'New Person'
    click_button 'Create Person'

    Person.count.should == 1

    visit '/'
    click_link 'People'
    within "tr[id='person_#{Person.first.id}'] td[class='col col-actions']" do
      click_link 'View'
    end

    click_link 'Add Person Information'
    select "#{Person.last.id}",
      from: "issue[person_id]",
      visible: false

    click_link "Add New Identification seed"
    fill_seed("identification",{
      number: '123456789',
    })

    select "national_id",
      from: "issue_identification_seeds_attributes_0_identification_kind_id",
      visible: false

    select "Argentina",
      from: "issue_identification_seeds_attributes_0_issuer",
      visible: false

    within(".has_many_container.identification_seeds") do
      click_link "Add New Attachment"
      fill_attachment('identification_seeds', 'jpg')
    end

    click_link "Add New Email seed"
    fill_seed("email",{
      address: 'tester@rspec.org',
    })

    select "work",
      from: "issue_email_seeds_attributes_0_email_kind_id",
      visible: false

    click_link "Add New Phone seed"
    fill_seed("phone",{
      number: '+541145250470',
      note: 'Only in office hours'
    })

    select "main",
      from: "issue_phone_seeds_attributes_0_phone_kind_id",
      visible: false

    select "Argentina",
      from: "issue[phone_seeds_attributes][0][country]",
      visible: false

    click_link "Add New Domicile seed"
    select "Argentina",
      from: "issue[domicile_seeds_attributes][0][country]",
      visible: false
    fill_seed('domicile', {
       state: 'Buenos Aires',
       city: 'C.A.B.A',
       street_address: 'Monroe',
       street_number: '4567',
       postal_code: '1657',
       floor: '1',
       apartment: 'C'
    })
    within(".has_many_container.domicile_seeds") do
      click_link "Add New Attachment"
      fill_attachment('domicile_seeds', 'zip')
    end

    click_link "Add New Allowance seed"
    fill_seed("allowance", {
      weight: "100",
      kind: "ARS",
      amount: "100"
    })

    within(".has_many_container.allowance_seeds") do
      click_link "Add New Attachment"
      fill_attachment('allowance_seeds', 'gif')
    end

    fill_seed("natural_docket", {
      first_name: "Lionel",
      last_name: "Higuain",
    }, false)

    select "married",
      from: "issue[natural_docket_seed_attributes][marital_status_id]",
      visible: false
    select "male",
      from: "issue[natural_docket_seed_attributes][gender_id]",
      visible: false
    select "Argentina",
      from: "issue[natural_docket_seed_attributes][nationality]",
      visible: false
    select "1985",
      from: "issue[natural_docket_seed_attributes][birth_date(1i)]",
      visible: false
    select "January",
      from: "issue[natural_docket_seed_attributes][birth_date(2i)]",
      visible: false
    select "1",
      from: "issue[natural_docket_seed_attributes][birth_date(3i)]",
      visible: false

    fill_seed("natural_docket", {
     job_title: "Programmer",
     job_description: "Develop cool software for the real people",
     politically_exposed_reason: "Nothing I am a legit guy!"
    }, false)


    #find("#natural_docket_seed", visible: false).click_link("Add New Attachment")
    within("#natural_docket_seed") do
       find('.has_many_container.attachments').click_link("Add New Attachment")
       fill_attachment('natural_docket_seed', 'png', false)
    end

    click_link "Add New Observation"

    select observation_reason.subject_en.truncate(140),
      from: "issue[observations_attributes][0][observation_reason_id]",
      visible: false
    select 'Admin', from: 'issue[observations_attributes][0][scope]', visible: false
    fill_in 'issue[observations_attributes][0][note]',
      with: 'Please check this guy on world check'

    click_button "Create Issue"

    issue = Issue.last
    observation = Observation.last
    assert_logging(issue, 0, 1)

    %i(identification_seeds domicile_seeds allowance_seeds).each do |seed|
      issue.send(seed).count.should == 1
      issue.send(seed).first.attachments.count == 1
    end

    issue.natural_docket_seed.should == NaturalDocketSeed.last
    issue.should be_observed
    observation.should be_new

    fill_in 'issue[observations_attributes][0][reply]',
      with: '0 hits go ahead!!!'
    click_button "Update Issue"

    issue.reload.should be_answered
    observation.reload.should be_answered

    click_link "Approve"

    issue.reload.should be_approved
    assert_logging(issue, 1, 2)
    Person.last.should be_enabled
  end

  it 'reviews a newly created customer' do
    person = create :new_natural_person
    issue = person.issues.first
    assert_logging(issue, 0, 1)
    observation_reason = create(:observation_reason)

    Issue.count.should == 1
    Person.count.should == 2
    DomicileSeed.count.should == 1
    IdentificationSeed.count.should == 1
    NaturalDocketSeed.count.should == 1
    AllowanceSeed.count.should == 2
    PhoneSeed.count.should == 1

    # assume that issue info is complete
    issue.complete!
    assert_logging(issue, 1, 1)

    # Admin does not see it as pending
    login_as admin_user

    expect(page).to have_content 'Signed in successfully.'

    # Admin sees issue in dashboard.
    expect(page).to have_content issue.id

    # Admin clicks in the issue to see the detail
    within("#issue_#{issue.id} td.col.col-actions") do
      click_link('View')
    end

    visit "/people/#{Person.first.id}/issues/#{Issue.last.id}"
    page.current_path.should == "/people/#{Person.first.id}/issues/#{Issue.last.id}/edit"

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
    select observation_reason.subject_en.truncate(140),
      from: "issue[observations_attributes][0][observation_reason_id]",
      visible: false
    select 'Client', from: 'issue[observations_attributes][0][scope]', visible: false
    fill_in 'issue[observations_attributes][0][note]',
      with: 'Please re-send your document'
    click_button 'Update Issue'

    assert_logging(issue, 1, 2)
    Observation.where(issue: issue).count.should == 1
    Issue.first.should be_observed

    # The issue goes away from the dashboard.
    click_link 'Dashboard'
    click_on 'Recent Issues'
    within "#recent-issues" do
      expect(page).to_not have_content(issue.id)
    end
    click_on 'Pending For Review'
    within "#pending-for-review" do
      expect(page).to_not have_content(issue.id)
    end

    get "/api/people/#{person.id}/issues/#{Issue.first.id}",
      headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

    issue_document = JSON.parse(response.body).deep_symbolize_keys

    # Customer re-submit his identification, via API
    issue_document[:included]
      .find{|x| x[:type] == 'identification_seeds' }
      .tap do |i|
        i[:attributes][:number] = '1234567890'
        i[:attributes][:issuer] = 'CO'
      end
    issue_document[:included]
      .find{|x| x[:type] == 'observations' }
      .tap do |i|
        i[:attributes] = {reply: "Va de vuelta el documento!!!"}
      end

    patch "/api/people/#{person.id}/issues/#{Issue.first.id}",
      params: JSON.dump(issue_document),
      headers: {"CONTENT_TYPE" => 'application/json',
                "Authorization" => "Token token=#{admin_user.api_token}"}

    assert_response 200

    Issue.first.should be_answered
    assert_logging(issue, 1, 4)
    Observation.first.reply.should_not be_nil

    IdentificationSeed.first.tap do |seed|
      seed.reload
      seed.issuer.should == "CO"
      seed.number.should == "1234567890"
    end

    visit '/'

    click_on 'Pending For Review'
    within("#issue_#{issue.id} td.col.col-actions") do
      click_link('View')
    end

    page.should have_content 'Reject'
    page.should have_content 'Dismiss'

    click_link 'Approve'

    Issue.last.should be_approved
    assert_logging(issue, 1, 5)
    Observation.last.should be_answered
    click_link 'Dashboard' 

    visit "/people/#{Person.first.id}/issues/#{Issue.last.id}/edit"
    page.current_path.should == "/people/#{Person.first.id}/issues/#{Issue.last.id}"
  end

  it "Edits a customer by creating a new issue" do
    observation_reason = create(:human_world_check_reason)
    person = create(:full_natural_person)
    login_as admin_user

    click_link 'People'

    within("tr[id='person_#{person.id}'] td[class='col col-actions']") do
      click_link('View')
    end

    click_link "Add Person Information"

    select "#{person.id}",
      from: "issue[person_id]",
      visible: false

    click_link "Add New Identification seed"
    fill_seed("identification",{
      number: '123456789',
    })

    select 'national_id',
      from: 'issue_identification_seeds_attributes_0_identification_kind_id',
      visible: false

    select 'Argentina',
      from: 'issue_identification_seeds_attributes_0_issuer',
      visible: false

    person.identifications.reload

    select person.identifications.first.id,
      from: "issue[identification_seeds_attributes][0][replaces_id]"

    within(".has_many_container.identification_seeds") do
      click_link "Add New Attachment"
      fill_attachment('identification_seeds', 'jpg')
    end

    find(:css, '#issue_identification_seeds_attributes_0_copy_attachments').set true

    click_link "Add New Domicile seed"

    select "Argentina",
      from: "issue[domicile_seeds_attributes][0][country]",
      visible: false
    fill_seed('domicile', {
       state: 'Buenos Aires',
       city: 'C.A.B.A',
       street_address: 'Monroe',
       street_number: '4567',
       postal_code: '1657',
       floor: '1',
       apartment: 'C'
    })

    person.domiciles.reload
    select person.domiciles.first.id, from: "issue[domicile_seeds_attributes][0][replaces_id]"

    within(".has_many_container.domicile_seeds") do
      click_link "Add New Attachment"
      fill_attachment('domicile_seeds', 'zip')
    end

    click_link "Add New Allowance seed"
    fill_seed("allowance", {
      weight: "100",
      kind: "ARS",
      amount: "100"
    })

   person.allowances.reload  
   select person.allowances.first.id, from: "issue[allowance_seeds_attributes][0][replaces_id]"

    within(".has_many_container.allowance_seeds") do
      click_link "Add New Attachment"
      fill_attachment('allowance_seeds', 'gif')
    end

    fill_seed("natural_docket", {
      first_name: "Lionel",
      last_name: "Higuain",
    }, false)

    select "married",
      from: "issue[natural_docket_seed_attributes][marital_status_id]",
      visible: false
    select "male",
      from: "issue[natural_docket_seed_attributes][gender_id]",
      visible: false
    select "Argentina",
      from: "issue[natural_docket_seed_attributes][nationality]",
      visible: false

    select "1985",
      from: "issue[natural_docket_seed_attributes][birth_date(1i)]",
      visible: false
    select "January",
      from: "issue[natural_docket_seed_attributes][birth_date(2i)]",
      visible: false
    select "1",
      from: "issue[natural_docket_seed_attributes][birth_date(3i)]",
      visible: false

    within("#natural_docket_seed") do
      click_link "Add New Attachment"
      fill_attachment('natural_docket_seed', 'png', false)
    end

    click_link "Add New Observation"

    select observation_reason.subject_en.truncate(140),
      from: "issue[observations_attributes][0][observation_reason_id]",
      visible: false
    select 'Admin', from: 'issue[observations_attributes][0][scope]', visible: false
    fill_in 'issue[observations_attributes][0][note]',
      with: 'Please check this guy on world check'

    click_button "Create Issue"
    issue = Issue.last
    assert_logging(issue, 0, 1)
    observation = Observation.last
    issue.should be_observed
    observation.should be_new

    fill_in 'issue[observations_attributes][0][reply]',
      with: '0 hits go ahead!!!'
    click_button "Update Issue"

    assert_logging(issue, 1, 1) 
    issue.reload.should be_answered
    observation.reload.should be_answered

    click_link "Approve"

    issue.reload.should be_approved

    old_domicile = Domicile.first
    new_domicile = Domicile.last
    old_identification = Identification.first
    new_identification = Identification.last
    old_allowance = Allowance.first
    new_allowance = Allowance.last
    old_natural_docket = NaturalDocket.first
    new_natural_docket = NaturalDocket.last

    old_domicile.replaced_by_id.should == new_domicile.id
    new_domicile.replaced_by_id.should be_nil

    old_identification.replaced_by_id.should == new_identification.id
    new_identification.replaced_by_id.should be_nil

    old_natural_docket.replaced_by_id.should == new_natural_docket.id
    new_natural_docket.replaced_by_id.should be_nil

    old_allowance.replaced_by_id.should == new_allowance.id
    new_allowance.replaced_by_id.should be_nil

    # Here we validate that attachments are copy to the new fruit (when applies)
    new_identification.attachments.count.should == 6
    new_natural_docket.attachments.count.should == 1

    within '.row.row-person' do
      click_link person.id
    end
    person.should be_enabled
  end

  it "Dismisses an issue that had only bogus data" do
    person = create :new_natural_person
    issue = person.issues.last
    issue.complete!
    assert_logging(issue, 0, 1)
    assert_logging(issue, 1, 1)
    login_as admin_user
    click_on "Recent Issues"
    visit "/people/#{issue.person.id}/issues/#{issue.id}"
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
    issue.complete!
    login_as admin_user
    click_on 'Pending For Review'
    visit "/people/#{issue.person.id}/issues/#{issue.id}"
    click_link 'Reject'

    issue.reload.should be_rejected
    person.reload.should_not be_enabled

    visit "/"
    expect(page).to_not have_content(issue.id)
  end

  it "Creates a user via API, asking for manual 'admin' worldcheck run" do
    reason = create :human_world_check_reason

    post "/api/people/",
      headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

    person = api_response.data

    issue_request = Api::IssuesHelper.issue_with_domicile_seed(:png)
    issue_request[:data][:relationships][:observations] = {
      data: [{type: 'observations', id: '@1'}]
    }
    issue_request[:included] << Api::IssuesHelper.observation_for(
      '@1', reason, "Please run worldcheck for them")
    issue_request[:data][:id] = "@1"

    post "/api/people/#{person.id}/issues",
      params: issue_request,
      headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

    login_as admin_user

    issue = api_response.data
    issue.attributes.state.should == 'observed'
    assert_logging(Issue.last, 0, 1)
    observation = api_response.included.find{|i| i.type == 'observations'}

    click_on 'Observations To Review'
    within("#observation_#{observation.id} td.col.col-actions") do
      click_link('View')
    end
    page.current_path.should == "/people/#{Person.last.id}/issues/#{issue.id}/edit"

    # Admin replies that there is not hits on worldcheck
    fill_in 'issue[observations_attributes][0][reply]', with: 'No hits'
    click_button 'Update Issue'
    assert_logging(Issue.last, 1, 1)

    get "/api/people/#{person.id}/issues/#{issue.id}",
      headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

    api_response.data.attributes.state.should == 'answered'
    api_response.included.find{|i| i.type == 'observations'}
      .attributes.state.should == 'answered'

    click_link 'Approve'

    get "/api/people/#{person.id}/issues/#{issue.id}",
      headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

    api_response.data.attributes.state.should == 'approved'

    click_link 'Dashboard'

    click_on 'Recent Issues'
    within ".recent_issues" do
      expect(page).to_not have_content(issue.id)
    end

    click_on 'Pending For Review'
    within ".pending_for_review" do
      expect(page).to_not have_content(issue.id)
    end

    get "/api/people/#{person.id}",
      headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

    api_response.data.attributes.enabled.should be_truthy

    visit "/people/#{person.id}/issues/#{issue.id}/edit"
    page.current_path.should == "/people/#{person.id}/issues/#{issue.id}"
  end

  it 'Reviews and disable a user with hits on worldcheck' do
    person = create :full_natural_person
    person.should be_enabled
    reason = create(:human_world_check_reason)

    issue_payload = Api::IssuesHelper.issue_with_an_observation(person.id,
      reason,
      "Please run worldcheck over this guy")

    post "/api/people/#{person.id}/issues",
      params: JSON.dump(issue_payload),
      headers: {"CONTENT_TYPE" => 'application/json',
                "Authorization" => "Token token=#{admin_user.api_token}"}

    assert_response 201

    issue = person.issues.last
    login_as admin_user
    issue.should be_observed
    assert_logging(Issue.last, 0, 1)
    
    click_on 'Recent Issues'
    within '.recent_issues.panel' do
      expect(page).to_not have_content(issue.id)
    end

    click_on 'Pending For Review'
    within '.pending_for_review.panel' do
      expect(page).to_not have_content(issue.id)
    end
    # Admin clicks in the observation to see the issue detail
    click_on 'Observations To Review'
    within("#observation_#{Observation.last.id} td.col.col-actions") do
      click_link('View')
    end
    page.current_path.should == "/people/#{person.id}/issues/#{Issue.last.id}/edit"

    # Admin replies that there is not hits on worldcheck
    fill_in 'issue[observations_attributes][0][reply]',
      with: '1 hits'
    click_button 'Update Issue'

    issue.reload.should be_answered
    assert_logging(Issue.last, 1, 1)
    Observation.last.should be_answered
  end

  it 'Creates a user via API, asking for robot worldcheck run' do
    reason = create :world_check_reason

    post "/api/people/",
      headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

    person = api_response.data

    issue_request = Api::IssuesHelper.issue_with_domicile_seed(:png)
    issue_request[:data][:relationships][:observations] = {
      data: [{type: 'observations', id: '@1'}]
    }
    issue_request[:included] << Api::IssuesHelper.observation_for(
      '@1', reason, "robot-worldcheck", 'robot')
    issue_request[:data][:id] = "@1"

    post "/api/people/#{person.id}/issues",
      params: issue_request.to_json,
      headers: {"CONTENT_TYPE" => 'application/json',
                "Authorization" => "Token token=#{admin_user.api_token}"}

    issue = api_response.data
    issue.attributes.state.should == 'observed'
    assert_logging(Issue.last, 0, 1)
    observation = api_response.included.find{|i| i.type == 'observations'}
    observation.attributes.scope.should == 'robot'

    login_as admin_user
    expect(page).to_not have_content(issue.id)

    # Simulate that robot perform check and notify to compliance
    get "/api/people/#{person.id}/issues/#{issue.id}",
      headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

    issue_request = json_response
    issue_request[:included]
      .find{|x| x[:type] == 'observations' }[:attributes] = {reply: "No hits"}

    patch "/api/people/#{person.id}/issues/#{issue.id}",
      params: issue_request.to_json,
      headers: {"CONTENT_TYPE" => 'application/json',
                "Authorization" => "Token token=#{admin_user.api_token}"}
    assert_response 200

    assert_logging(Issue.last, 1, 2)

    api_response.data.attributes.state.should == 'answered'
    api_response.included.find{|i| i.type == 'observations'}
      .attributes.state.should == 'answered'

    visit '/'
    click_on 'Pending For Review'
    within("#issue_#{issue.id} td.col.col-actions") do
      click_link('View')
    end
    page.current_path.should == "/people/#{Person.last.id}/issues/#{issue.id}/edit"

    click_link 'Approve'

    get "/api/people/#{person.id}/issues/#{issue.id}",
      headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

    api_response.data.attributes.state.should == 'approved'

    click_link 'Dashboard'
    expect(page).to_not have_content(issue.id)

    get "/api/people/#{person.id}",
      headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

    api_response.data.attributes.enabled.should be_truthy

    visit "/people/#{person.id}/issues/#{issue.id}/edit"
    page.current_path.should == "/people/#{person.id}/issues/#{issue.id}"
  end

  it "Abandons a new person issue that was inactive" do
    person = create :new_natural_person
    issue = person.issues.last
    issue.complete!

    assert_logging(Issue.last, 0, 1)
    assert_logging(Issue.last, 1, 1)

    login_as admin_user
    click_on 'Pending For Review'
    visit "/people/#{person.id}/issues/#{issue.id}"
    click_link 'Abandon'

    issue.reload.should be_abandoned
    person.reload.should_not be_enabled

    visit "/"
    expect(page).to_not have_content(issue.id)
  end

  describe 'when admin edits an issue' do
    it 'can edit a particular seed' do
      issue_request = Api::IssuesHelper.issue_with_domicile_seed(:png)
      issue_request[:data][:relationships][:natural_docket_seed] = {
        data: {id: '@1', type: 'natural_docket_seeds'}}
      issue_request[:included] += Api::IssuesHelper.natural_docket_seed(:jpg)
      issue_request[:included][0][:attributes][:copy_attachments] = true

      post api_person_issues_path(create(:full_natural_person).id),
        params: issue_request.to_json,
        headers: {"CONTENT-TYPE": 'application/json',
                  "Authorization": "Token token=#{admin_user.api_token}"}

      issue = api_response.data

      login_as admin_user
      click_on 'Drafts'
      within("tr[id='issue_#{issue.id}'] td[class='col col-actions']") do
        click_link('View')
      end

      within ".has_many_container.domicile_seeds" do
        select "Argentina",
        from: "issue[domicile_seeds_attributes][0][country]",
        visible: false

        fill_seed('domicile', {
          state: 'Buenos Aires',
          city: 'C.A.B.A',
          street_address: 'Ayacucho',
          street_number: '4567',
          postal_code: '1657',
          floor: '1',
          apartment: 'C'
        })

        select Domicile.first.id, from: "issue[domicile_seeds_attributes][0][replaces_id]"

        find(:css, "#issue_domicile_seeds_attributes_0_attachments_attributes_0__destroy").set(true)
        click_link "Add New Attachment"
        fill_attachment('domicile_seeds', 'gif', true, 0, 1)
      end

      click_button "Update Issue"
      issue = Issue.last
      issue.should be_draft

      assert_logging(Issue.last, 0, 1)
      assert_logging(Issue.last, 1, 1)

      click_link "Approve"
      issue.reload.should be_approved
      assert_logging(Issue.last, 1, 2)

      old_domicile = Domicile.first
      new_domicile = Domicile.last

      old_domicile.replaced_by_id.should == new_domicile.id
      new_domicile.replaced_by_id.should be_nil
      new_domicile.attachments.count.should == 6

      within '.row.row-person' do
      	click_link Person.first.id
      end
    end

    it 'can add new seeds' do
      person = create(:full_natural_person)
      issue_request = Api::IssuesHelper.issue_with_current_person(person.id)
      post api_person_issues_path(person.id),
        params: issue_request.to_json,
        headers: {"CONTENT-TYPE": 'application/json',
                  "Authorization": "Token token=#{admin_user.api_token}"}
      issue = api_response.data

      login_as admin_user
      click_on 'Drafts'
      within("tr[id='issue_#{issue.id}'] td[class='col col-actions']") do
        click_link('View')
      end

      click_link "Add New Identification seed"
      fill_seed("identification",{
        number: '123456789'
      })

      select 'national_id',
        from: 'issue_identification_seeds_attributes_0_identification_kind_id',
        visible: false

      select 'Argentina',
        from: 'issue_identification_seeds_attributes_0_issuer',
        visible: false

      within(".has_many_container.identification_seeds") do
        click_link "Add New Attachment"
        fill_attachment('identification_seeds', 'jpg')
      end

      click_link "Add New Domicile seed"

      select "Argentina",
       from: "issue[domicile_seeds_attributes][0][country]",
       visible: false
      fill_seed('domicile', {
        state: 'Buenos Aires',
        city: 'C.A.B.A',
        street_address: 'Monroe',
        street_number: '4567',
        postal_code: '1657',
        floor: '1',
        apartment: 'C'
      })
      within(".has_many_container.domicile_seeds fieldset:nth-of-type(1)") do
        click_link "Add New Attachment"
        fill_attachment('domicile_seeds', 'zip')
      end

      click_button "Update Issue"
      issue = Issue.last
      issue.should be_draft

      assert_logging(Issue.last, 0, 1)
      assert_logging(Issue.last, 1, 1)

      click_link "Approve"
      issue.reload.should be_approved

      assert_logging(Issue.last, 1, 2)

      within ".row.row-person" do
        click_link person.id
      end

      person.reload.domiciles.count == 2
      person.reload.identifications.count == 2
    end

    it 'can remove existing seeds' do
      person = create :new_natural_person
      issue = person.issues.first

      Issue.count.should == 1
      Person.count.should == 2
      DomicileSeed.count.should == 1
      IdentificationSeed.count.should == 1
      NaturalDocketSeed.count.should == 1
      AllowanceSeed.count.should == 2

      # Admin does not see it as pending
      login_as admin_user

      expect(page).to have_content 'Signed in successfully.'

      # Admin sees issue in dashboard.
      click_on 'Drafts'
      expect(page).to have_content issue.id

      within("#issue_#{issue.id} td.col.col-actions") do
        click_link('View')
      end
      page.current_path.should == "/people/#{Person.first.id}/issues/#{Issue.last.id}/edit"

      visit "/people/#{Person.first.id}/issues/#{Issue.last.id}"
      page.current_path.should == "/people/#{Person.first.id}/issues/#{Issue.last.id}/edit"

      expect(page).to have_content 'Identification'
      expect(page).to have_content 'Domicile'
      expect(page).to have_content 'Natural Docket'
      expect(page).to have_content 'Allowance seed'

      within '.has_many_container.identification_seeds' do
        click_link 'Remove Entity'
        page.driver.browser.switch_to.alert.accept
      end

      within '.has_many_container.allowance_seeds' do
        first(:link, 'Remove Entity').click
        page.driver.browser.switch_to.alert.accept
      end

      DomicileSeed.count.should == 1
      IdentificationSeed.count.should == 0
      NaturalDocketSeed.count.should == 1

      visit "/people/#{person.id}/issues/#{Issue.last.id}"

      click_link "Add New Identification seed"
      fill_seed("identification",{
        number: '123456789'
      })

      select 'national_id',
        from: 'issue_identification_seeds_attributes_0_identification_kind_id',
        visible: false

      select 'Argentina',
        from: 'issue_identification_seeds_attributes_0_issuer',
        visible: false

      within(".has_many_container.identification_seeds") do
        click_link "Add New Attachment"
        fill_attachment('identification_seeds', 'jpg')
      end

      click_button 'Update Issue'
      assert_logging(Issue.last, 0, 1)
      assert_logging(Issue.last, 1, 1) 

      click_link 'Approve'
      issue.reload.should be_approved
      assert_logging(Issue.last, 1, 2)

      within '.row.row-person' do
      	click_link  person.id
      end
      person.allowances.reload
      person.identifications.reload
      person.allowances.first.weight.should == AllowanceSeed.last.weight
      person.identifications.first.number.should == IdentificationSeed.last.number
    end
  end

  it 'manually enables/disables and sets risk for a person' do
    person = create(:full_natural_person)

    login_as admin_user

    click_link 'People'

    within("#person_#{person.id} td.col.col-actions") do
      click_link('Edit')
    end
    page.current_path.should == "/people/#{person.id}/edit"

    find(:css, "#person_enabled").set(false)
    select 'low', from: 'person_risk', visible: false
    click_button 'Update Person'

    page.current_path.should == "/people/#{person.id}"

    person.reload.should_not be_enabled
    person.risk.should == 'low'
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
