require 'rails_helper'

describe 'People' do
  let(:admin_user) { create(:admin_user) }

  it 'loads and search for rejected people' do
    person = create :new_natural_person
    person.reject!
    person.reload

    login_as admin_user
    click_link('People')
    click_link('All')

    email_address = person.issues.last.email_seeds.last.address
    fill_in :q_emails_address_or_issues_email_seeds_address_cont, with: email_address
    fill_in :q_identifications_number_or_issues_identification_seeds_number_or_argentina_invoicing_details_tax_id_or_chile_invoicing_details_tax_id_cont,
            with: person.issues.last.identification_seeds.last.number
    fill_in :q_natural_dockets_first_name_or_issues_natural_docket_seed_first_name_cont,
            with: person.issues.last.natural_docket_seed.first_name
    fill_in :q_natural_dockets_last_name_or_issues_natural_docket_seed_last_name_cont,
            with: person.issues.last.natural_docket_seed.last_name
    click_on 'Filter'

    expect(page).to have_content("(#{person.id})")
  end
end
