require 'rails_helper'

describe 'an admin handling affinities' do
  let(:admin_user) { create(:admin_user) }

  it 'creates a legal entity and set the related people' do
    login_as admin_user

    # We set the already approved people
    owner_one = create(:new_natural_person)
    owner_two = create(:full_legal_entity_person)
    payee_one = create(:new_natural_person)
    payee_two = create(:full_natural_person)

    person = create(:full_legal_entity_person)
    visit '/'
    click_link 'People'
    within "tr[id='person_#{person.id}'] td[class='col col-actions']" do
      click_link 'View'
    end

    click_link 'Add Person Information'
    click_button 'Create new issue'

    issue = Issue.last
    person = issue.person

    find('li[title="Affinity"] a').click
    
    add_affinities([owner_one, owner_two], 'owner', 0)
    add_affinities([payee_one, payee_two], 'payee', 2)

    click_button "Update Issue"

    visit '/'

    click_on 'Draft'

    within "tr[id='issue_#{issue.id}'] td[class='col col-id']" do
      click_link "#{issue.id}"
    end

    click_link 'Complete'
    
    click_link 'Approve'

    click_link 'Dashboard' 

    visit "/people/#{person.id}"

    find('li[title="Affinity"] a').click
    
    expect(page).to have_content "RELATED PERSON (#{owner_one.id})"
    expect(page).to have_content "RELATED PERSON (#{owner_two.id}) 🏭: E Corp"
    expect(page).to have_content "RELATED PERSON (#{payee_one.id})"
    expect(page).to have_content "RELATED PERSON (#{payee_two.id}) ☺: Joe Doe" 

    visit "/people/#{owner_one.id}"
    
    find('li[title="Affinity"] a').click
    
    within("#attributes_table_affinity_4 .row.row-affinity_kind") do
      expect(page).to have_content 'owns'
    end
  end

  it 'forwards validation error when two people are already linked with the same kind' do 
    person = create(:full_natural_person)

    related_person = person.reload.affinities.first.related_person
    related_person.update!(enabled: true)
    login_as admin_user

    click_link 'People'

    within("tr[id='person_#{person.id}'] td[class='col col-actions']") do
      click_link('View')
    end

    click_link "Add Person Information"
    click_button "Create new issue"

    find('li[title="Affinity"] a').click
    add_affinities([related_person], 'business_partner', 0)

    click_button 'Update Issue'

    expect(page).to have_selector('.validation_errors', visible: true)
  
    find('li[title="Affinity"] a').click

    click_link 'Remove'
    add_affinities([related_person], 'payee', 0)

    click_button 'Update Issue'
    
    within '.flash.flash_notice' do 
      expect(page).to have_content 'Issue was successfully updated.'
    end

    click_link 'Complete'

    issue = Issue.last
    visit "/people/#{person.id}/issues/#{issue.id}"
    click_link 'Approve'

    visit "/people/#{person.id}"
    find('li[title="Affinity"] a').click

    within("#attributes_table_affinity_#{Affinity.last.id}") do
      expect(page).to have_content 'payee'
      expect(page).to have_content '(1) ☺: Joe Doe'
      expect(page).to have_content '(2) ☺:'
    end
  end

  it 'can replace an affinity with same related ones and different kind without issues' do
    person = create(:full_natural_person)

    related_person = person.reload.affinities.first.related_person
    login_as admin_user

    click_link 'People'

    within("tr[id='person_#{person.id}'] td[class='col col-actions']") do
      click_link('View')
    end

    click_link "Add Person Information"
    click_button "Create new issue"

    find('li[title="Affinity"] a').click

    add_affinities([related_person], 'stakeholder', 0)

    select_with_search(
      "#issue_affinity_seeds_attributes_0_replaces_input", 
      "Affinity##{Affinity.last.id}: business_partner (#{related_person.id}) ☺: Joe…")

    click_button 'Update Issue'

    click_link 'Complete'

    issue = Issue.last
    visit "/people/#{person.id}/issues/#{issue.id}"
    click_link 'Approve'

    visit "/people/#{person.id}"
    find('li[title="Affinity"] a').click

    within("#attributes_table_affinity_#{Affinity.last.id}") do
      expect(page).to have_content 'stakeholder'
      expect(page).to have_content '(1) ☺: Joe Doe'
      expect(page).to have_content '(2) ☺:'
    end
  end
end
