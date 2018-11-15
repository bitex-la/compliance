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

    
    click_link "人 #{owner_one.id}: Joe Doe"
    click_link 'Affinities'

    within("#attributes_table_affinity_6 .row.row-affinity_kind") do
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

    click_link 'Affinity'
    add_affinities([related_person], 'business_partner', 0)

    click_button 'Update Issue'

    expect(page).to have_selector('.validation_errors', visible: true)
  
    click_link 'Affinity'
    click_link 'Remove'
    add_affinities([related_person], 'payee', 0)

    click_button 'Update Issue'
    
    within '.flash.flash_notice' do 
      expect(page).to have_content 'Issue was successfully updated.'
    end

    click_link 'Complete'
    click_link 'Approve'

    visit "/people/#{person.id}"
    click_link 'Affinities'

    within("#attributes_table_affinity_#{Affinity.last.id}") do
      expect(page).to have_content 'payee'
      expect(page).to have_content '人 1: Joe Doe'
      expect(page).to have_content '人 2:'
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

    click_link 'Affinity'

    add_affinities([related_person], 'stakeholder', 0)
    set_replacement("Affinity##{Affinity.last.id}: business_partner 人 #{related_person.id}", 0)

    click_button 'Update Issue'

    click_link 'Complete'
    click_link 'Approve'

    visit "/people/#{person.id}"
    click_link 'Affinities'

    within("#attributes_table_affinity_#{Affinity.last.id}") do
      expect(page).to have_content 'stakeholder'
      expect(page).to have_content '人 1: Joe Doe'
      expect(page).to have_content '人 2:'
    end
  end
end

def add_affinities(related_ones, kind, start_index)
  related_ones.each_with_index do |related, index|
    click_link "Add New Affinity seed"
    address = related.reload.emails.first.address

    within "#issue_affinity_seeds_attributes_#{start_index + index}_affinity_kind_id_input" do
      find('.select2.select2-container.select2-container--default', 
        match: :first).click
    end
    find(".select2-search__field").set(kind)
    within ".select2-results" do
      find("li", text: kind).click
    end

    within "#issue_affinity_seeds_attributes_#{start_index + index}_related_person_id_input" do 
      find_all('.select2.select2-container.select2-container--default')
        .to_a.first.click
    end
    find(".select2-search__field").set(address)
    within ".select2-results" do
      find_all("li", text: address).first.click
    end
  end

  def set_replacement(keyword, index)
    within "#issue_affinity_seeds_attributes_#{index}_replaces_input" do 
      find_all('.select2.select2-container.select2-container--default')
        .to_a.first.click
    end
    find(".select2-search__field").set(keyword)
    within ".select2-results" do
      find_all("li", text: keyword).first.click
    end
  end
end
