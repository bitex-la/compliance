require 'rails_helper'

describe 'an admin user' do
  let(:compliance_admin_user) { create(:compliance_admin_user) }
  let(:admin_user) { create(:admin_user) }

  it 'cleans up the current admin user after responding' do
    login_as admin_user
    visit '/'
    expect(page).to have_content 'Dashboard'
    visit '/api/issues'
    expect(page).to have_content 'total_items'
    visit '/'
    click_link 'Logout'
    expect(page).to have_content 'Signed out successfully'
    visit '/api/issues'
    expect(page).to have_content 'forbidden'
  end

  it 'creates a new natural person and its issue via admin' do
    AdminUser.current_admin_user = compliance_admin_user
    observation_reason = create(:human_world_check_reason)

    login_as compliance_admin_user

    click_link 'People'
    click_link 'New Person'
    click_button 'Create Person'

    Person.count.should == 1

    visit '/'
    click_link 'People'
    click_link 'All'
    within "tr[id='person_#{Person.first.id}'] td[class='col col-actions']" do
      click_link 'View'
    end

    click_link 'Add Person Information'
    click_button 'Create new issue'

    fulfil_new_issue_form
    add_observation(observation_reason, 'Please check this guy on world check')

    click_button "Update Issue"
    click_link "Edit"

    issue = Issue.last
    observation = Observation.last
    assert_logging(issue, :create_entity, 1)
    assert_logging(issue, :update_entity, 4)
    assert_logging(issue.reload, :observe_issue, 1)

    %i(identification_seeds domicile_seeds allowance_seeds).each do |seed|
      issue.send(seed).count.should == 1
      issue.send(seed).first.attachments.count == 1
    end

    issue.identification_seeds.first.attachments
      .first.document_file_name.should == 'an_simple_????.jpg'

    issue.domicile_seeds.first.attachments
      .first.document_file_name.should == 'an_simple_????.zip'

    issue.allowance_seeds.first.attachments
      .first.document_file_name.should == 'an_simple_????.gif'

    issue.natural_docket_seed.should == NaturalDocketSeed.last
    issue.should be_observed
    observation.should be_new

    find('li[title="Observations"] a').click

    fill_in 'issue[observations_attributes][0][reply]',
      with: '0 hits go ahead!!!'

    click_button "Update Issue"

    click_link "Edit"
    
    find('li[title="Risk scores"] a').click

    within '.external_links' do
      expect(page).to have_content 'Link #1'
      expect(page).to have_content 'Link #2'
    end

    within '.extra_info' do
      expect(page)
        .to have_content "link: #{"https://issuu.com/mop_chile0/docs/15_proyectos_de_restauraci_n".truncate(40, omission:'...')}"
      expect(page).to have_content 'title: de 18 mil familias de clase media - P...'
    end

    assert_logging(issue, :update_entity, 7)
    issue.reload.should be_answered
    observation.reload.should be_answered

    add_observation(1, observation_reason, 'Please check this again')

    click_button "Update Issue"
    click_link "Edit"

    issue.reload.should be_observed
    assert_logging(issue.reload, :observe_issue, 2)
    
    find('li[title="Observations"] a').click
    
    fill_in 'issue[observations_attributes][1][reply]',
      with: '0 hits at 2018-06-07'

    click_button "Update Issue"

    click_link "Approve"
    
    visit "/people/#{issue.person.id}"
    
    issue.reload.should be_approved
    assert_logging(issue, :update_entity, 13)
    expect(issue.person.enabled).to be_falsey
    expect(issue.person.state).to eq('new')
    assert_logging(issue.person, :enable_person, 0)

    find('li[title="Risk scores"] a').click

    within '.external_links' do
      expect(page).to have_content 'Link #1'
      expect(page).to have_content 'Link #2'
    end

    within '.extra_info' do
      expect(page).to have_content "link: #{"https://issuu.com/mop_chile0/docs/15_proyectos_de_restauraci_n".truncate(40, omission:'...')}"
      expect(page).to have_content 'title: de 18 mil familias de clase media - P...'
    end

    click_link 'Enable'

    expect(issue.person.reload.enabled).to be_truthy
    expect(issue.person.state).to eq('enabled')
    assert_logging(issue.person, :enable_person, 1)
    
    click_link 'Edit Person'
    click_link 'Disable'
    assert_logging(issue.person, :enable_person, 1)
    assert_logging(issue.person, :disable_person, 1)
    expect(issue.person.reload.enabled).to be_falsey
    expect(issue.person.state).to eq('disabled')

    click_link 'Edit Person'
    click_link 'Enable'

    expect(issue.person.reload.enabled).to be_truthy
    expect(issue.person.state).to eq('enabled')
    assert_logging(issue.person, :enable_person, 2)

    visit "/allowances/#{issue.person.allowances.first.id}"
    
    within '#page_title' do
      expect(page).to have_content 'Allowance#1'
    end
  end

  # TODO: Uncomment when workflow implementation are ready for production
  # it 'creates a new natural person and its issue via admin with workflows' do
  #   AdminUser.current_admin_user = admin_user
  #   observation_reason = create(:human_world_check_reason)
   
  #   login_as compliance_admin_user

  #   click_link 'People'
  #   click_link 'New Person'
  #   click_button 'Create Person'

  #   Person.count.should == 1

  #   visit '/'
  #   click_link 'People'
  #   click_link 'All'
  #   within "tr[id='person_#{Person.first.id}'] td[class='col col-actions']" do
  #     click_link 'View'
  #   end

  #   click_link 'Add Person Information'
  #   click_button 'Create new issue'
    
  #   fulfil_new_issue_form true

  #   click_button "Update Issue"
  #   click_link "Edit"

  #   issue = Issue.last
  #   assert_logging(issue, :create_entity, 1)

  #   # Fake here that an implementor set workflow tasks
  #   task_one = create(:basic_task, workflow: issue.workflows.first)
  #   task_two = create(:basic_task, workflow: issue.workflows.first)

  #   %i(identification_seeds domicile_seeds allowance_seeds).each do |seed|
  #     issue.send(seed).count.should == 1
  #     issue.send(seed).first.attachments.count == 1
  #   end

  #   issue.identification_seeds.first.attachments
  #     .first.document_file_name.should == 'an_simple_????.jpg'

  #   issue.domicile_seeds.first.attachments
  #     .first.document_file_name.should == 'an_simple_????.zip'

  #   issue.allowance_seeds.first.attachments
  #     .first.document_file_name.should == 'an_simple_????.gif'

  #   issue.natural_docket_seed.should == NaturalDocketSeed.last
  #   issue.should be_draft
    
  #   find('li[title="Risk scores"] a').click

  #   within '.external_links' do
  #     expect(page).to have_content 'Link #1'
  #     expect(page).to have_content 'Link #2'
  #   end

  #   within '.extra_info' do
  #     expect(page)
  #       .to have_content "link: #{"https://issuu.com/mop_chile0/docs/15_proyectos_de_restauraci_n".truncate(40, omission:'...')}"
  #     expect(page).to have_content 'title: de 18 mil familias de clase media - P...'
  #   end

  #   assert_logging(issue, :update_entity, 5)
  #   issue.reload.should be_draft

  #   expect(page).to_not have_content("Approve")

  #   task_one.start!
  #   task_one.update!(output: 'All ok')
  #   task_one.finish!

  #   click_button "Update Issue"
  #   click_link "Edit"

  #   find('li[title="Workflows"] a').click
  #   expect(page).to have_content("workflow completed at 50%")
    
  #   task_two.start!
  #   task_two.update!(output: 'All ok')
  #   task_two.finish!

  #   issue.complete!

  #   #fake here that issue goes to answered
  #   issue.workflows.first.finish!

  #   expect(issue.reload.state).to eq 'new'

  #   click_button "Update Issue"
  #   click_link "Edit"

  #   find('li[title="Workflows"] a').click
  #   expect(page).to have_content("workflow completed at 100%")

  #   click_link "Cancel"

  #   expect(page).to have_content("Approve")
  #   click_link "Approve"
    
  #   visit "/people/#{issue.person.id}"
    
  #   issue.reload.should be_approved
  #   assert_logging(issue, :update_entity, 17)
  #   expect(issue.person.enabled).to be_falsey
  #   expect(issue.person.state).to eq('new')
  #   assert_logging(issue.person, :enable_person, 0)

  #   find('li[title="Risk scores"] a').click

  #   within '.external_links' do
  #     expect(page).to have_content 'Link #1'
  #     expect(page).to have_content 'Link #2'
  #   end

  #   within '.extra_info' do
  #     expect(page).to have_content "link: #{"https://issuu.com/mop_chile0/docs/15_proyectos_de_restauraci_n".truncate(40, omission:'...')}"
  #     expect(page).to have_content 'title: de 18 mil familias de clase media - P...'
  #   end

  #   click_link 'Enable'

  #   expect(issue.person.reload.enabled).to be_truthy
  #   expect(issue.person.state).to eq('enabled')
  #   assert_logging(issue.person, :enable_person, 1)
    
  #   click_link 'Edit Person'
  #   click_link 'Disable'
  #   assert_logging(issue.person, :enable_person, 1)
  #   assert_logging(issue.person, :disable_person, 1)
  #   expect(issue.person.reload.enabled).to be_falsey
  #   expect(issue.person.state).to eq('disabled')

  #   click_link 'Edit Person'
  #   click_link 'Enable'

  #   expect(issue.person.reload.enabled).to be_truthy
  #   expect(issue.person.state).to eq('enabled')
  #   assert_logging(issue.person, :enable_person, 2)

  #   visit "/allowances/#{issue.person.allowances.first.id}"
    
  #   within '#page_title' do
  #     expect(page).to have_content 'Allowance#1'
  #   end
  # end

  it 'reviews a newly created customer' do
    person = create :new_natural_person
    issue = person.issues.reload.first
    assert_logging(issue, :create_entity, 1)
    observation_reason = create(:observation_reason)
    wc_observation_reason = create(:world_check_reason)

    wc_observation = Observation.create!(
      observation_reason: wc_observation_reason,
      note: 'Run a WC screening for this guy',
      issue: issue,
      scope: 'robot'
    )

    # assume that issue info is complete
    #issue.complete!
    assert_logging(issue, :update_entity, 1)

    # Admin does not see it as pending
    login_as compliance_admin_user

    expect(page).to have_content 'Signed in successfully.'
    click_on 'Observed'

    # Admin sees issue in dashboard.
    expect(page).to have_content issue.id

    # Admin clicks in the issue to see the detail
    within("#issue_#{issue.id} td.col.col-id") do
      click_link(issue.id)
    end

    click_link "Edit"

    visit "/people/#{Person.first.id}/issues/#{issue.id}/edit"
    page.current_path.should == "/people/#{Person.first.id}/issues/#{issue.id}/edit"

    find('li[title="Identifications"] a').click
    expect(page).to have_content 'Identification seed'
    find('li[title="Domiciles"] a').click
    expect(page).to have_content 'Domicile seed'
    find('li[title="Natural dockets"] a').click
    expect(page).to have_content 'Natural Docket'
    find('li[title="Risk scores"] a').click
    within '.has_many_container.risk_score_seeds' do
      expect(page).to have_content 'userId: 5'
      expect(page).to have_content 'score: green'
    end
    find('li[title="Allowances"] a').click
    expect(page).to have_content 'Allowance seed'

    # Admin verify the attachment(s)
    have_xpath("//li[@class='has_many_container attachments']", count: 4)
    within first "li.has_many_container.attachments" do
      within first "fieldset.inputs.has_many_fields" do
        expect(page).to have_content AllowanceSeed.first.attachments.first.name
      end
    end

    api_update "/observations/#{wc_observation.id}", {
      type: 'observations',
      id: wc_observation.id,
      attributes: {reply: 'All ok'}
    }

    add_observation(1, observation_reason, 'Please re-send your document')
          
    click_button 'Update Issue'

    assert_logging(issue, :update_entity, 6)
    assert_logging(issue.reload, :observe_issue, 2)

    Observation.where(issue: issue).count.should == 2
    issue.reload.should be_observed

    # The issue goes away from the dashboard.
    click_link 'Dashboard'

    identification_seed = issue.reload.identification_seeds.first

    api_update "/identification_seeds/#{identification_seed.id}", {
      type: 'identification_seeds',
      id: identification_seed.id,
      attributes: { number: '1234567890', issuer: 'CO' }
    }

    observation = issue.observations.last
    api_update "/observations/#{observation.id}", {
      type: 'observations',
      id: observation.id,
      attributes: {reply: 'Va de vuelta el documento!!!'}
    }

    assert_logging(issue, :update_entity, 7)
    assert_logging(issue.reload, :observe_issue, 2)

    assert_response 200

    identification_seed.reload.tap do |seed|
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

    click_link "Edit"

    find('li[title="Observations"] a').click

    fill_in 'issue[observations_attributes][0][reply]',
      with: 'Double checked by compliance'

    click_button 'Update Issue'
    
    click_link 'Approve'

    issue.reload.should be_approved
    assert_logging(issue, :update_entity, 11)
    wc_observation.reload.should be_answered
    wc_observation.reply.should == 'Double checked by compliance'
    Observation.last.should be_answered
    click_link 'Dashboard' 

    visit "/people/#{person.id}/issues/#{issue.id}/edit"
    page.current_path.should == "/people/#{person.id}/issues/#{issue.id}"
    assert_logging(person, :enable_person, 0)

    visit "/people/#{issue.person.id}"

    click_link 'Edit Person'
    click_link 'Enable'

    expect(issue.person.reload.enabled).to be_truthy
    expect(issue.person.state).to eq('enabled')
    assert_logging(issue.person, :enable_person, 1)
  end

  it "Edits a customer by creating a new issue" do
    observation_reason = create(:human_world_check_reason)
    person = create(:full_natural_person)
    login_as compliance_admin_user

    click_link 'People'
    click_link 'All'

    within("tr[id='person_#{person.id}'] td[class='col col-actions']") do
      click_link('View')
    end

    click_link "Add Person Information"
    click_button "Create new issue"

    find('li[title="Identifications"] a').click
    click_link "Add New Identification seed"
    fill_seed("identification",{
      number: '123456789',
      issuer: 'AR' 
    })

    select_with_search(
      '#issue_identification_seeds_attributes_0_identification_kind_id_input',
      'national_id'
    )

    person.identifications.reload

    select_with_search(
      '#issue_identification_seeds_attributes_0_replaces_input',
      person.identifications.first.name
    )

    within(".has_many_container.identification_seeds") do
      click_link "Add New Attachment"
      fill_attachment('identification_seeds', 'jpg')
    end

    find(:css, '#issue_identification_seeds_attributes_0_copy_attachments').set true

    find('li[title="Domiciles"] a').click
    click_link "Add New Domicile seed"

    fill_seed('domicile', {
      country: 'AR',
      state: 'Buenos Aires',
      city: 'C.A.B.A',
      street_address: 'Monroe',
      street_number: '4567',
      postal_code: '1657',
      floor: '1',
      apartment: 'C'
    })

    person.domiciles.reload

    select_with_search(
      '#issue_domicile_seeds_attributes_0_replaces_input',
      person.domiciles.first.name
    )

    within(".has_many_container.domicile_seeds") do
      click_link "Add New Attachment"
      fill_attachment('domicile_seeds', 'zip')
    end

    find('li[title="Allowances"] a').click
    click_link "Add New Allowance seed"

    select_with_search(
      '#issue_allowance_seeds_attributes_0_kind_id_input',
      'us_dollar'
    )
    fill_seed("allowance", {
      amount: "100"
    })

    person.allowances.reload  
    select_with_search(
      '#issue_allowance_seeds_attributes_0_replaces_input',
      person.allowances.first.name
    )

    within(".has_many_container.allowance_seeds") do
      click_link "Add New Attachment"
      fill_attachment('allowance_seeds', 'gif')
    end

    find('li[title="Natural dockets"] a').click

    select_with_search(
      '#issue_natural_docket_seed_attributes_marital_status_id_input',
      'married'
    )  
    select_with_search(
      '#issue_natural_docket_seed_attributes_gender_id_input',
      'male'
    )

    fill_seed("natural_docket", {
      nationality: 'AR',
      first_name: "Lionel",
      last_name: "Higuain",
      birth_date: "1985-01-01"
    }, false)

    within("#natural_docket_seed") do
      click_link "Add New Attachment"
      fill_attachment('natural_docket_seed', 'png', false)
    end

    add_observation(observation_reason, 'Please check this guy on world check')

    click_button "Update Issue"
    click_link "Edit"

    issue = Issue.last
    assert_logging(issue, :create_entity, 1)
    assert_logging(issue.reload, :observe_issue, 1)
    observation = Observation.last
    issue.should be_observed
    observation.should be_new

    find('li[title="Observations"] a').click
    fill_in 'issue[observations_attributes][0][reply]',
      with: '0 hits go ahead!!!'
    click_button "Update Issue"
    click_link "Edit"

    assert_logging(issue, :update_entity, 7) 
    issue.reload.should be_answered
    observation.reload.should be_answered

    Timecop.travel 2.days.from_now
  
    add_observation(1, observation_reason, 'Please check this guy on FBI database')
    add_observation(2, observation_reason, 'Please check this on SII')

    click_button "Update Issue"
    click_link "Edit"

    assert_logging(issue.reload, :observe_issue, 2)

    find('li[title="Observations"] a').click

    fill_in 'issue[observations_attributes][1][reply]',
      with: '0 hits go ahead!!!'
    
    fill_in 'issue[observations_attributes][2][reply]',
      with: 'He is OK on SII'  

    click_button "Update Issue"

    click_link "Approve"
    
    issue.reload.should be_approved
    assert_logging(person, :enable_person, 1)

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
    new_identification.attachments.count.should == 12
    new_natural_docket.attachments.count.should == 1

    person.should be_enabled
    expect(person.state).to eq('enabled')
  end

  it "Dismisses an issue that had only bogus data" do
    person = create :new_natural_person
    issue = person.issues.reload.last
    issue.complete!
    assert_logging(issue, :create_entity, 1)
    assert_logging(issue, :update_entity, 1)
    login_as compliance_admin_user
    click_on "Fresh"
    visit "/people/#{issue.person.id}/issues/#{issue.id}"
    click_link 'Dismiss'

    issue.reload.should be_dismissed
    person.reload.should_not be_enabled
  end

  it "Rejects an issue because an observation went unanswered" do
    person = create :new_natural_person, enabled: true
    person.should be_enabled
    expect(person.state).to eq('enabled')
    issue = person.issues.reload.last
    issue.complete!
    login_as compliance_admin_user
    click_on 'Answered'
    visit "/people/#{issue.person.id}/issues/#{issue.id}"
    click_link 'Reject'

    issue.reload.should be_rejected
    person.reload.should be_enabled
    expect(person.state).to eq('enabled')
    assert_logging(person, :disable_person, 0)
  end

  it "Creates a user via API, asking for manual 'admin' worldcheck run" do
    reason = create :human_world_check_reason
    person = create(:empty_person)
    issue = create(:full_natural_person_issue, person: person)
    observation = create(:robot_observation, issue: issue)

    login_as compliance_admin_user
    assert_logging(issue, :create_entity, 1)

    click_on 'Observed'
    within("#issue_#{issue.id} td.col.col-id") do
      click_link(issue.id)
    end

    click_link "Edit"

    page.current_path.should ==
      "/people/#{person.id}/issues/#{issue.id}/edit"

    find('li[title="Observations"] a').click
    # Admin replies that there is not hits on worldcheck
    fill_in 'issue[observations_attributes][0][reply]', with: 'No hits'
    click_button 'Update Issue'
    assert_logging(issue, :update_entity, 4)

    click_link 'Approve'

    visit "/people/#{person.id}/issues/#{issue.id}/edit"
    page.current_path.should == "/people/#{person.id}/issues/#{issue.id}"
    page.should have_content 'Approved'
  end

  it 'Handles a race condition between admin and robot observation replies' do
    person = create :new_natural_person
    person.should_not be_enabled
    expect(person.state).to eq('new')
    wc_reason = create(:world_check_reason, subject_en: 'Run WC')
    google_reason = create(:world_check_reason, subject_en: 'Run Negative Path')
    observation_reason = create(:observation_reason)
    issue = person.issues.reload.first

    wc_observation = create(:robot_observation, 
      observation_reason: wc_reason,
      issue: issue)

    google_observation = create(:robot_observation, 
      observation_reason: google_reason,
      issue: issue)

    issue.reload.should be_observed  
    login_as compliance_admin_user

    click_on 'Observed'
    within("#issue_#{issue.id} td.col.col-id") do
      click_link(issue.id)
    end

    click_link "Edit"

    find('li[title="Observations"] a').click
    click_link "Add New Observation"

    select_with_search(
      '#issue_observations_attributes_2_observation_reason_input',
      observation_reason.subject_en.truncate(40, omission:'…')
    )
    select_with_search(  
      '#issue_observations_attributes_2_scope_input',
      'Client'
    )

    fill_in 'issue[observations_attributes][2][note]',
      with: 'Please check your ID info'


    click_button 'Update Issue'
    click_link 'Dashboard'

    identification_seed = issue.reload.identification_seeds.first
    api_update "/identification_seeds/#{identification_seed.id}", {
      type: 'identification_seeds',
      id: identification_seed.id,
      attributes: { number: '95579427', issuer: 'AR' }
    }

    visit '/'
    
    click_on 'Observed'
    within("#issue_#{issue.id} td.col.col-id") do
      click_link(issue.id)
    end

    click_link "Edit"

    api_update "/observations/#{google_observation.id}", {
      type: 'observations',
      id: google_observation.id,
      attributes: {reply: 'Ok'}
    }

    find('li[title="Observations"] a').click

    fill_in 'issue[observations_attributes][0][reply]',
      with: 'No hits'

    click_button 'Update Issue'
    click_link "Edit"

    find('li[title="Observations"] a').click
    fill_in 'issue[observations_attributes][2][reply]',
      with: 'ID is ok'
    
    api_update "/observations/#{wc_observation.id}", {
      type: 'observations',
      id: wc_observation.id,
      attributes: {reply: nil}
    }

    click_button 'Update Issue'
    issue.reload.should be_answered
  end

  it 'Reviews and disable a user with hits on worldcheck' do
    person = create :full_natural_person
    person.should be_enabled
    expect(person.state).to eq('enabled')
    reason = create(:human_world_check_reason)
    issue = create(:basic_issue, person: person)
    observation = create(:robot_observation, issue: issue)
    issue.reload.should be_observed
    assert_logging(issue.reload, :observe_issue, 1)

    login_as compliance_admin_user
    
    # Admin clicks in the observation to see the issue detail
    click_on 'Observed'
    within("#issue_#{issue.id} td.col.col-id") do
      click_link(issue.id)
    end
    click_link "Edit"

    page.current_path.should == "/people/#{person.id}/issues/#{issue.id}/edit"

    find('li[title="Observations"] a').click
    # Admin replies that there is not hits on worldcheck
    fill_in 'issue[observations_attributes][0][reply]',
      with: '1 hits'
    click_button 'Update Issue'

    issue.reload.should be_answered
    assert_logging(Issue.last, :update_entity, 4)
    assert_logging(issue.reload, :observe_issue, 1)
    Observation.last.should be_answered
    click_link 'Reject'
    person.reload.should be_enabled
    expect(person.state).to eq('enabled')
  end

  it "Abandons a new person issue that was inactive" do
    person = create :new_natural_person
    issue = person.issues.reload.last
    issue.complete!

    assert_logging(issue, :create_entity, 1)
    assert_logging(issue, :update_entity, 1)

    login_as compliance_admin_user
    click_on 'Answered'
    
    visit "/people/#{person.id}/issues/#{issue.id}"
    click_link 'Abandon'

    issue.reload.should be_abandoned
    person.reload.should_not be_enabled
    expect(person.state).to eq('new')

    visit '/'
    click_on "Abandoned"
    expect(page).to have_content(issue.id)
  end

  describe 'when admin edits an issue' do
    it 'can edit a particular seed' do
      person = create(:full_natural_person).reload
      issue = create(:full_natural_person_issue, person: person)

      login_as compliance_admin_user
      click_on 'Draft'
      within("tr[id='issue_#{issue.id}'] td[class='col col-id']") do
        click_link(issue.id)
      end
      click_link "Edit"

      find('li[title="Domiciles"] a').click

      select_with_search(
        '#issue_domicile_seeds_attributes_0_replaces_input',
        Domicile.first.name
      )

      within ".has_many_container.domicile_seeds" do
        fill_seed('domicile', {
          country: 'AR',
          state: 'Buenos Aires',
          city: 'C.A.B.A',
          street_address: 'Ayacucho',
          street_number: '4567',
          postal_code: '1657',
          floor: '1',
          apartment: 'C'
        })

        find(:css, "#issue_domicile_seeds_attributes_0_attachments_attributes_0__destroy").set(true)
        click_link "Add New Attachment"
        fill_attachment('domicile_seeds', 'gif', true, 0, 11)
      end

      click_button "Update Issue"
      issue = person.issues.last
      issue.should be_draft

      assert_logging(issue, :create_entity, 1)
      assert_logging(issue, :update_entity, 3)

      click_link "Approve"
      issue.reload.should be_approved
      assert_logging(issue, :update_entity, 4)

      old_domicile = Domicile.first
      new_domicile = Domicile.last

      old_domicile.replaced_by_id.should == new_domicile.id
      new_domicile.replaced_by_id.should be_nil
      new_domicile.attachments.count.should == 11
    end

    it 'can add new seeds' do
      person = create(:full_natural_person)
      issue = create(:basic_issue, person: person)

      login_as compliance_admin_user
      click_on 'Draft'
      within("tr[id='issue_#{issue.id}'] td[class='col col-id']") do
        click_link(issue.id)
      end

      click_link "Edit"

      find('li[title="Identifications"] a').click
      
      click_link "Add New Identification seed"
      fill_seed("identification",{
        number: '123456789',
        issuer: 'AR'
      })

      select_with_search(
        '#issue_identification_seeds_attributes_0_identification_kind_id_input',
        'national_id'
      )

      within(".has_many_container.identification_seeds") do
        click_link "Add New Attachment"
        fill_attachment('identification_seeds', 'jpg')
      end

      find('li[title="Domiciles"] a').click
      
      click_link "Add New Domicile seed"

      fill_seed('domicile', {
        country: 'AR',
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
      issue.should be_draft

      assert_logging(Issue.last, :create_entity, 1)
      assert_logging(Issue.last, :update_entity, 3)

      click_link "Approve"
      issue.reload.should be_approved

      assert_logging(Issue.last, :update_entity, 4)

      person.reload.domiciles.count == 2
      person.reload.identifications.count == 2
    end

    it 'can remove existing attachments' do
      person = create :new_natural_person
      issue = person.issues.reload.first

      # Admin does not see it as pending
      login_as compliance_admin_user

      expect(page).to have_content 'Signed in successfully.'

      # Admin sees issue in dashboard.
      click_on 'Draft'
      expect(page).to have_content issue.id

      within("#issue_#{issue.id} td.col.col-id") do
        click_link(issue.id)
      end

      click_link "Edit"
      page.current_path.should == "/people/#{person.id}/issues/#{issue.id}/edit"

      visit "/people/#{person.id}/issues/#{issue.reload.id}"
      click_link "Edit"

      page.current_path.should == "/people/#{person.id}/issues/#{issue.id}/edit"

      find('li[title="Identifications"] a').click
      within '.has_many_container.identification_seeds' do
        find(:css, '#issue_identification_seeds_attributes_0_attachments_attributes_0__destroy').set true
      end

      find('li[title="Allowances"] a').click
      within '.has_many_container.allowance_seeds' do
        find(:css, '#issue_allowance_seeds_attributes_0_attachments_attributes_0__destroy').set true
      end

      visit "/people/#{person.id}/issues/#{issue.id}"
      click_link "Edit"

      find('li[title="Identifications"] a').click
      click_link "Add New Identification seed"
      fill_seed("identification",{
        number: '123456789',
        issuer: 'AR'
      })

      select_with_search(
        '#issue_identification_seeds_attributes_0_identification_kind_id_input',
        'national_id'
      )

      within(".has_many_container.identification_seeds") do
        within first(".has_many_container.attachments") do
          click_link "Add New Attachment"
          fill_attachment('identification_seeds', 'jpg', true, 0, 11)
        end
      end

      click_button 'Update Issue'
      assert_logging(issue, :create_entity, 1)
      assert_logging(issue, :update_entity, 5) 


      visit "/people/#{person.id}/issues/#{issue.id}"
      click_link 'Approve'
      issue.reload.should be_approved
      assert_logging(issue, :update_entity, 7)

      person.allowances.reload
      person.identifications.reload
      person.allowances.first.weight.should == AllowanceSeed.last.weight
      person.identifications.first.number.should == IdentificationSeed.last.number
    end
  end

  it 'can edit an issue' do
    person = create(:full_natural_person).reload
    issue = create(:full_natural_person_issue, person: person)

    login_as compliance_admin_user

    click_on 'Draft'
    within("tr[id='issue_#{issue.id}'] td[class='col col-id']") do
      click_link(issue.id)
    end
    
    click_link "Edit"

    find('li[title="Natural dockets"] a').click

    fill_seed('natural_docket', {
      first_name: 'Joe',
      last_name: 'Jameson',
      birth_date: "1975-01-15"
    }, false)
    
 
    find('li[title="Domiciles"] a').click
    
    select_with_search(
      '#issue_domicile_seeds_attributes_0_replaces_input',
      Domicile.first.name
    )

    within ".has_many_container.domicile_seeds" do
      fill_seed('domicile', {
        country: 'AR',
        state: 'Buenos Aires',
        city: 'C.A.B.A',
        street_address: 'Triunvirato',
        street_number: '2300',
        postal_code: '1254',
        floor: '',
        apartment: ''
      })
    end

    click_button "Update Issue"

    click_link "Edit"

    find('li[title="Domiciles"] a').click

    accept_alert do
      click_link 'Remove'
    end

    Capybara.using_wait_time(10) do
      expect(page).to have_content('Domicile seed was successfully destroyed.')
    end
  end

  it 'manually enables/disables and sets risk for a person' do
    person = create(:full_natural_person)

    login_as compliance_admin_user

    click_link 'People'
    click_link 'All'

    within("#person_#{person.id} td.col.col-actions") do
      click_link('Edit')
    end
    page.current_path.should == "/people/#{person.id}/edit"

    click_link 'Disable'

    click_link 'Edit Person'

    select_with_search('#person_risk_input', 'low')
    click_button 'Update Person'

    person.reload.should_not be_enabled
    expect(person.state).to eq('disabled')
    person.risk.should == 'low'
  end

  it "don't show api token for admin users in view page" do
    login_as compliance_admin_user

    click_link 'Admin Users'
    within("#admin_user_#{admin_user.id} td.col.col-actions") do
      click_link 'View'
    end

    expect(page.current_path).to eq("/admin_users/#{admin_user.id}")
    expect(page).to_not have_text 'API TOKEN'
    expect(page).to_not have_text admin_user.api_token
  end

  it "don't show sensible data for admin users in csv export" do
    login_as compliance_admin_user

    click_link 'Admin Users'
    click_link 'CSV'
    DownloadHelpers::wait_for_download
    csv = File.read(DownloadHelpers::download)
    expect(csv).to_not include('API TOKEN')
    expect(csv).to_not include(admin_user.api_token)
    expect(csv).not_to include("Encrypted password")
    expect(csv).to_not include(admin_user.encrypted_password)
    expect(csv).not_to include("Reset password token")
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
