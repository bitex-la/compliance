require 'rails_helper'

describe 'an admin handling affinities' do
  let(:admin_user) { create(:admin_user) }

  it 'creates a legal entity and set the related people' do
    login_as admin_user

    # We set the already approved people
    owner_one = create(:full_natural_person)
    owner_two = create(:full_legal_entity_person)
    payee_one = create(:full_natural_person)
    payee_two = create(:full_natural_person)

    click_link 'People'
    click_link 'New Person'
    click_button 'Create Person'

    visit '/'
    click_link 'People'
    within "tr[id='person_#{Person.last.id}'] td[class='col col-actions']" do
      click_link 'View'
    end

    click_link 'Add Person Information'
    click_button 'Create new issue'

    issue = Issue.last
    person = issue.person

    click_link 'Docket'

    fill_seed('legal_entity_docket', {
      commercial_name: 'Crypto soccer',
      legal_name: 'Crypto sports LLC',
      industry: 'World domination',
      business_description: 'Sell electronics'
    }, false)

    within("#legal_entity_docket_seed") do
      find('.has_many_container.attachments').click_link("Add New Attachment")
      fill_attachment('legal_entity_docket_seed', 'png', false)
    end

    click_link 'Domicile (0)' 
    click_link "Add New Domicile seed"
    select "Argentina",
      from: "issue[domicile_seeds_attributes][0][country]",
      visible: false
    fill_seed('domicile', {
       state: 'Buenos Aires',
       city: 'C.A.B.A',
       street_address: 'Manuel Ugarte',
       street_number: '1567',
       postal_code: '2657',
       floor: '7',
    })
    within(".has_many_container.domicile_seeds") do
      click_link "Add New Attachment"
      fill_attachment('domicile_seeds', 'zip', true, 0, 0, true)
    end

    click_link 'ID (0)'
    click_link "Add New Identification seed"
    fill_seed("identification",{
      number: '20955794280',
    })

    select "tax_id",
      from: "issue_identification_seeds_attributes_0_identification_kind_id",
      visible: false

    select "Argentina",
      from: "issue_identification_seeds_attributes_0_issuer",
      visible: false

    within(".has_many_container.identification_seeds") do
      click_link "Add New Attachment"
      fill_attachment('identification_seeds', 'jpg', true, 0, 0, true)
    end

    click_link 'Allowance (0)' 
    click_link "Add New Allowance seed"

    select "us_dollar",
      from: "issue[allowance_seeds_attributes][0][kind_id]",
      visible: false
    fill_seed("allowance", {
      amount: "1000000"
    })

    within(".has_many_container.allowance_seeds") do
      click_link "Add New Attachment"
      fill_attachment('allowance_seeds', 'gif', true, 0, 0, true)
    end

    click_link 'Contact (0)'
    click_link "Add New Email seed"
    fill_seed("email",{
      address: 'sales@evilcorp.com',
    })

    select "work",
      from: "issue_email_seeds_attributes_0_email_kind_id",
      visible: false

    click_link "Add New Phone seed"
    fill_seed("phone",{
      number: '+541145230470',
      note: 'Only in office hours'
    })

    select "main",
      from: "issue_phone_seeds_attributes_0_phone_kind_id",
      visible: false

    select "Argentina",
      from: "issue[phone_seeds_attributes][0][country]",
      visible: false

    click_link 'Affinity'
    add_affinities([owner_one, owner_two], 'owner', 0)
    add_affinities([payee_one, payee_two], 'payee', 2)

    click_button "Update Issue"

    visit '/'

    click_on 'Draft'
    within("#issue_#{issue.id} td.col.col-id") do
      click_link(issue.id)
    end

    click_link 'Complete'
    click_link 'Approve'
    click_link 'Dashboard' 

    visit "/people/#{person.id}"

    click_link 'Affinities'

    expect(page).to have_content "RELATED PERSON 人 #{owner_one.id}: Joe Doe"
    expect(page).to have_content "RELATED PERSON 人 #{owner_two.id}: E Corp"
    expect(page).to have_content "RELATED PERSON 人 #{payee_one.id}: Joe Doe"
    expect(page).to have_content "RELATED PERSON 人 #{payee_two.id}: Joe Doe" 

    visit "/people/#{owner_one.id}"
    click_link 'Affinities'

    within("#attributes_table_affinity_5 .row.row-affinity_kind") do
      expect(page).to have_content 'own'
    end
  end
end

def add_affinities(related_ones, kind, start_index)
  related_ones.each_with_index do |related, index|
    click_link "Add New Affinity seed"
    select kind,
      from: "issue_affinity_seeds_attributes_#{start_index + index}_affinity_kind_id",
      visible: false

    fill_seed("affinity",{
      related_person_id: related.id
    }, true, start_index + index)
  end
end
