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
    click_button 'Create new issue'
    
    click_link 'ID (0)'
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

    click_link 'Contact (0)'
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

    click_link 'Domicile (0)' 
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

    click_link 'Allowance (0)' 
    click_link "Add New Allowance seed"

    select "us_dollar",
      from: "issue[allowance_seeds_attributes][0][kind_id]",
      visible: false
    fill_seed("allowance", {
      amount: "100"
    })

    within(".has_many_container.allowance_seeds") do
      click_link "Add New Attachment"
      fill_attachment('allowance_seeds', 'gif')
    end

    click_link 'Docket' 
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

    click_link "Base"
    click_link "Add New Observation"

    select observation_reason.subject_en.truncate(40, omission:'…'),
      from: "issue[observations_attributes][0][observation_reason_id]",
      visible: false
    select 'Admin', from: 'issue[observations_attributes][0][scope]', visible: false
    fill_in 'issue[observations_attributes][0][note]',
      with: 'Please check this guy on world check'

    click_button "Update Issue"

    issue = Issue.last
    observation = Observation.last
    assert_logging(issue, :create_entity, 1)

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
    assert_logging(issue, :update_entity, 4)
    Person.last.should be_enabled
  end

  it 'reviews a newly created customer' do
    person = create :new_natural_person
    issue = person.issues.reload.first
    assert_logging(issue, :create_entity, 1)
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
    assert_logging(issue, :update_entity, 1)

    # Admin does not see it as pending
    login_as admin_user

    expect(page).to have_content 'Signed in successfully.'

    # Admin sees issue in dashboard.
    expect(page).to have_content issue.id

    # Admin clicks in the issue to see the detail
    within("#issue_#{issue.id} td.col.col-id") do
      click_link(issue.id)
    end

    visit "/people/#{Person.first.id}/issues/#{Issue.last.id}"
    page.current_path.should == "/people/#{Person.first.id}/issues/#{Issue.last.id}/edit"

    click_link 'ID (1)'
    expect(page).to have_content 'Identification seed'
    click_link 'Domicile (1)'
    expect(page).to have_content 'Domicile seed'
    click_link 'Docket'
    expect(page).to have_content 'Natural Docket'
    click_link 'Allowance (2)'
    expect(page).to have_content 'Allowance seed'

    # Admin verify the attachment(s)
    have_xpath("//li[@class='has_many_container attachments']", count: 4)
    within first "li.has_many_container.attachments" do
      within first "fieldset.inputs.has_many_fields" do
        expect(page).to have_content AllowanceSeed.first.attachments.first.name
      end
    end

    # Admin sends an observation to customer about their identification (it was blurry)
    click_link 'Base'
    click_link 'Add New Observation'
    select observation_reason.subject_en.truncate(40, omission:'…'),
      from: "issue[observations_attributes][0][observation_reason_id]",
      visible: false
    select 'Client', from: 'issue[observations_attributes][0][scope]', visible: false
    fill_in 'issue[observations_attributes][0][note]',
      with: 'Please re-send your document'
    click_button 'Update Issue'

    assert_logging(issue, :update_entity, 3)
    Observation.where(issue: issue).count.should == 1
    Issue.first.should be_observed

    # The issue goes away from the dashboard.
    click_link 'Dashboard'

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
    assert_logging(issue, :update_entity, 5)
    Observation.first.reply.should_not be_nil

    IdentificationSeed.first.tap do |seed|
      seed.reload
      seed.issuer.should == "CO"
      seed.number.should == "1234567890"
    end

    visit '/'

    click_on 'Answered'
    within("#issue_#{issue.id} td.col.col-id") do
      click_link(issue.id)
    end

    page.should have_content 'Reject'
    page.should have_content 'Dismiss'

    click_link 'Approve'

    Issue.last.should be_approved
    assert_logging(issue, :update_entity, 6)
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
    click_button "Create new issue"

    click_link "ID (0)"
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

    click_link "Domicile (0)"
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

    click_link "Allowance (0)"
    click_link "Add New Allowance seed"
    select "us_dollar",
      from: "issue[allowance_seeds_attributes][0][kind_id]",
      visible: false
    fill_seed("allowance", {
      amount: "100"
    })

   person.allowances.reload  
   select person.allowances.first.name, from: "issue[allowance_seeds_attributes][0][replaces_id]"

    within(".has_many_container.allowance_seeds") do
      click_link "Add New Attachment"
      fill_attachment('allowance_seeds', 'gif')
    end

    click_link "Docket"
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

    click_link "Base"
    click_link "Add New Observation"

    select observation_reason.subject_en.truncate(40, omission:'…'),
      from: "issue[observations_attributes][0][observation_reason_id]",
      visible: false
    select 'Admin', from: 'issue[observations_attributes][0][scope]', visible: false
    fill_in 'issue[observations_attributes][0][note]',
      with: 'Please check this guy on world check'

    click_button "Update Issue"
    issue = Issue.last
    assert_logging(issue, :create_entity, 1)
    observation = Observation.last
    issue.should be_observed
    observation.should be_new

    fill_in 'issue[observations_attributes][0][reply]',
      with: '0 hits go ahead!!!'
    click_button "Update Issue"

    assert_logging(issue, :update_entity, 3) 
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
    issue = person.issues.reload.last
    issue.complete!
    assert_logging(issue, :create_entity, 1)
    assert_logging(issue, :update_entity, 1)
    login_as admin_user
    click_on "Fresh"
    visit "/people/#{issue.person.id}/issues/#{issue.id}"
    click_link 'Dismiss'

    issue.reload.should be_dismissed
    person.reload.should_not be_enabled
  end

  it "Rejects an issue because an observation went unanswered" do
    person = create :new_natural_person, enabled: true
    person.should be_enabled
    issue = person.issues.reload.last
    issue.complete!
    login_as admin_user
    click_on 'Answered'
    visit "/people/#{issue.person.id}/issues/#{issue.id}"
    click_link 'Reject'

    issue.reload.should be_rejected
    person.reload.should_not be_enabled
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
    assert_logging(Issue.last, :create_entity, 1)
    observation = api_response.included.find{|i| i.type == 'observations'}

    click_on 'Observed'
    within("#issue_#{issue.id} td.col.col-id") do
      click_link(issue.id)
    end
    page.current_path.should == "/people/#{Person.last.id}/issues/#{issue.id}/edit"

    # Admin replies that there is not hits on worldcheck
    fill_in 'issue[observations_attributes][0][reply]', with: 'No hits'
    click_button 'Update Issue'
    assert_logging(Issue.last, :update_entity, 2)

    get "/api/people/#{person.id}/issues/#{issue.id}",
      headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

    api_response.data.attributes.state.should == 'answered'
    api_response.included.find{|i| i.type == 'observations'}
      .attributes.state.should == 'answered'

    click_link 'Approve'

    get "/api/people/#{person.id}/issues/#{issue.id}",
      headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

    api_response.data.attributes.state.should == 'approved'

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

    issue = person.issues.reload.last
    login_as admin_user
    issue.should be_observed
    assert_logging(Issue.last, :create_entity, 1)
    
    # Admin clicks in the observation to see the issue detail
    click_on 'Observed'
    within("#issue_#{issue.id} td.col.col-id") do
      click_link(issue.id)
    end
    page.current_path.should == "/people/#{person.id}/issues/#{Issue.last.id}/edit"

    # Admin replies that there is not hits on worldcheck
    fill_in 'issue[observations_attributes][0][reply]',
      with: '1 hits'
    click_button 'Update Issue'

    issue.reload.should be_answered
    assert_logging(Issue.last, :update_entity, 2)
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
    assert_logging(Issue.last, :create_entity, 1)
    observation = api_response.included.find{|i| i.type == 'observations'}
    observation.attributes.scope.should == 'robot'

    login_as admin_user

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

    assert_logging(Issue.last, :update_entity, 3)

    api_response.data.attributes.state.should == 'answered'
    api_response.included.find{|i| i.type == 'observations'}
      .attributes.state.should == 'answered'

    visit '/'
    click_on 'Answered'
    within("#issue_#{issue.id} td.col.col-id") do
      click_link(issue.id)
    end
    page.current_path.should == "/people/#{Person.last.id}/issues/#{issue.id}/edit"

    click_link 'Approve'

    get "/api/people/#{person.id}/issues/#{issue.id}",
      headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

    api_response.data.attributes.state.should == 'approved'

    get "/api/people/#{person.id}",
      headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

    api_response.data.attributes.enabled.should be_truthy

    visit "/people/#{person.id}/issues/#{issue.id}/edit"
    page.current_path.should == "/people/#{person.id}/issues/#{issue.id}"
  end

  it "Abandons a new person issue that was inactive" do
    person = create :new_natural_person
    issue = person.issues.reload.last
    issue.complete!

    assert_logging(Issue.last, :create_entity, 1)
    assert_logging(Issue.last, :update_entity, 1)

    login_as admin_user
    click_on 'Answered'
    visit "/people/#{person.id}/issues/#{issue.id}"
    click_link 'Abandon'

    issue.reload.should be_abandoned
    person.reload.should_not be_enabled

    visit '/'
    click_on "Abandoned"
    expect(page).to have_content(issue.id)
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
      click_on 'Draft'
      within("tr[id='issue_#{issue.id}'] td[class='col col-id']") do
        click_link(issue.id)
      end

      click_link 'Domicile (1)'
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

      assert_logging(Issue.last, :create_entity, 1)
      assert_logging(Issue.last, :update_entity, 1)

      click_link "Approve"
      issue.reload.should be_approved
      assert_logging(Issue.last, :update_entity, 2)

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
      click_on 'Draft'
      within("tr[id='issue_#{issue.id}'] td[class='col col-id']") do
        click_link(issue.id)
      end

      click_link "ID (0)"
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

      click_link "Domicile (0)"
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

      assert_logging(Issue.last, :create_entity, 1)
      assert_logging(Issue.last, :update_entity, 1)

      click_link "Approve"
      issue.reload.should be_approved

      assert_logging(Issue.last, :update_entity, 2)

      within ".row.row-person" do
        click_link person.id
      end

      person.reload.domiciles.count == 2
      person.reload.identifications.count == 2
    end

    it 'can remove existing seeds' do
      person = create :new_natural_person
      issue = person.issues.reload.first

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
      click_on 'Draft'
      expect(page).to have_content issue.id

      within("#issue_#{issue.id} td.col.col-id") do
        click_link(issue.id)
      end
      page.current_path.should == "/people/#{Person.first.id}/issues/#{Issue.last.id}/edit"

      visit "/people/#{Person.first.id}/issues/#{Issue.last.id}"
      page.current_path.should == "/people/#{Person.first.id}/issues/#{Issue.last.id}/edit"

      click_link "ID (1)"
      within '.has_many_container.identification_seeds' do
        find(:css, '#issue_identification_seeds_attributes_0_attachments_attributes_0__destroy').set true
      end

      click_link "Allowance (2)"
      within '.has_many_container.allowance_seeds' do
        find(:css, '#issue_allowance_seeds_attributes_0_attachments_attributes_0__destroy').set true
      end

      DomicileSeed.count.should == 1
      IdentificationSeed.count.should == 1
      NaturalDocketSeed.count.should == 1

      visit "/people/#{person.id}/issues/#{Issue.last.id}"

      click_link "ID (1)"
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
        within first(".has_many_container.attachments") do
          click_link "Add New Attachment"
          fill_attachment('identification_seeds', 'jpg', true, 0, 5)
        end
      end

      click_button 'Update Issue'
      assert_logging(Issue.last, :create_entity, 1)
      assert_logging(Issue.last, :update_entity, 0) 

      click_link 'Approve'
      issue.reload.should be_approved
      assert_logging(Issue.last, :update_entity, 1)

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
