module FeatureHelpers
  def login_as(admin_user)
    visit admin_user_session_path
    fill_in 'admin_user[email]', with: admin_user.email
    fill_in 'admin_user[password]', with: admin_user.password
    click_button 'Login'
  end

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

  def fill_attachment(kind, ext = 'jpg', has_many = true, index = 0, att_index = 0, accented = false)
    wait_for_ajax
    path = if has_many
      "issue[#{kind}_attributes][#{index}][attachments_attributes][#{att_index}][document]"
    else
      "issue[#{kind}_attributes][attachments_attributes][#{att_index}][document]"
    end
    filename = if accented
      "./spec/fixtures/files/áñ_simple_微信图片.#{ext}"
    else
      if ext == ext.upcase
        "./spec/fixtures/files/simple_upper.#{ext}"
      else 
        "./spec/fixtures/files/simple.#{ext}"
      end
    end
    attach_file(path,
        File.absolute_path(filename), wait: 10.seconds)
  end

  def add_affinities(related_ones, kind, start_index)
    related_ones.each_with_index do |related, index|
      click_link "Add New Affinity seed"

      address =  if related.reload.enabled	
        related.emails.first.address	
      else	
        related.issues.first.email_seeds.first.address	
      end

      select_with_search(
        "#issue_affinity_seeds_attributes_#{start_index + index}_affinity_kind_id_input",
        kind)

      select_with_search(
        "#issue_affinity_seeds_attributes_#{start_index + index}_related_person_id_input", 
        address)
    end
  end

  def select_with_search(selector, value)
    within selector do 
      find_all('.select2.select2-container.select2-container--default')
        .to_a.first.click
    end
    find(".select2-search__field").set(value)
    within ".select2-results" do
      find_all("li", text: value).first.click
    end
  end

  def fulfil_new_issue_form
    click_link 'ID (0)'
    click_link "Add New Identification seed"
    fill_seed("identification",{
      number: '123456789',
    })

    select_with_search(
      '#issue_identification_seeds_attributes_0_identification_kind_id_input',
      'national_id'
    )

    select_with_search(
      '#issue_identification_seeds_attributes_0_issuer_input',
      'Argentina'
    )

    within(".has_many_container.identification_seeds") do
      click_link "Add New Attachment"
      fill_attachment('identification_seeds', 'jpg', true, 0, 0, true)
    end

    click_link 'Contact (0)'
    click_link "Add New Email seed"
    fill_seed("email",{
      address: 'tester@rspec.org',
    })

    select_with_search(
      '#issue_email_seeds_attributes_0_email_kind_id_input',
      'work'
    )

    click_link "Add New Phone seed"
    fill_seed("phone",{
      number: '+541145250470',
      note: 'Only in office hours'
    })

    select_with_search(
      '#issue_phone_seeds_attributes_0_phone_kind_id_input',
      'main'
    )

    select_with_search(
      '#issue_phone_seeds_attributes_0_country_input',
      'Argentina'
    )

    click_link 'Domicile (0)' 
    click_link "Add New Domicile seed"
   
    select_with_search(
      '#issue_domicile_seeds_attributes_0_country_input',
      'Argentina'
    )

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
      fill_attachment('domicile_seeds', 'zip', true, 0, 0, true)
    end

    click_link 'Allowance (0)' 
    click_link "Add New Allowance seed"

    select_with_search(
      '#issue_allowance_seeds_attributes_0_kind_id_input',
      'us_dollar'
    )
   
    fill_seed("allowance", {
      amount: "100"
    })

    within(".has_many_container.allowance_seeds") do
      click_link "Add New Attachment"
      fill_attachment('allowance_seeds', 'gif', true, 0, 0, true)
    end

    click_link 'Docket' 
    fill_seed("natural_docket", {
      first_name: "Lionel",
      last_name: "Higuain",
    }, false)

    select_with_search(
      '#issue_natural_docket_seed_attributes_marital_status_id_input',
      'married'
    )  
    select_with_search(
      '#issue_natural_docket_seed_attributes_gender_id_input',
      'male'
    )
    select_with_search(
      '#issue_natural_docket_seed_attributes_nationality_input',
      'Argentina'
    )

    fill_seed("natural_docket", {
     job_title: "Programmer",
     job_description: "Develop cool software for the real people",
     politically_exposed_reason: "Nothing I am a legit guy!",
     birth_date: "1985-01-01"
    }, false)

    within("#natural_docket_seed") do
      find('.has_many_container.attachments').click_link("Add New Attachment")
      fill_attachment('natural_docket_seed', 'png', false)
    end

    click_link 'Risk Score (0)' 
    click_link "Add New Risk score seed"

    fill_seed('risk_score', {
      score: 'green',
      provider: 'bing',
      external_link: 'https://goo.gl/vVvoK5,https://goo.gl/YpV5CZ',
      extra_info: File.read('spec/fixtures/risk_score/serp_api_with_hits.json')
    })

    within(".has_many_container.risk_score_seeds") do
      click_link "Add New Attachment"
      fill_attachment('risk_score_seeds', 'gif', true, 0, 0, true)
    end
  end

  def add_observation(index = 0, reason, note)
    click_link "Base"
    click_link "Add New Observation"
  
    select_with_search(
      "#issue_observations_attributes_#{index}_observation_reason_input",
      reason.subject_en.truncate(40, omission:'…')
    )
    select_with_search(  
      "#issue_observations_attributes_#{index}_scope_input",
      reason.scope.capitalize
    )
  
    fill_in "issue[observations_attributes][#{index}][note]",
      with: note
  end
end

RSpec.configuration.include FeatureHelpers, type: :feature
