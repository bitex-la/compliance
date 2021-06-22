require 'rails_helper'

describe 'people' do
  let(:compliance_admin_user) { create(:compliance_admin_user) }

  it 'download csv' do
    data = [
      {
        email: 'jhon@doe.com',
        first_name: 'Jhon',
        last_name: 'Doe'
      },
      {
        email: 'mike@test.com',
        first_name: 'Mike',
        last_name: 'Jhonson'
      },
      {
        email: 'frank@test.com',
        first_name: 'Frank',
        last_name: 'Constanza'
      },
      {
        email: 'pete@test.com',
        first_name: 'Peter',
        last_name: 'Clark'
      },
      {
        email: 'mary@doe.com',
        first_name: 'Mary',
        last_name: 'Doe'
      }
    ]
    5.times do |n|
      person = create(:empty_person)
      issue = create(:basic_issue, reason: IssueReason.new_client)
      create(:fixed_full_email_seed, address: data[n][:email], person: person, issue: issue)
      seed = create(:full_natural_docket_seed,
                    person: person,
                    issue: issue,
                    first_name: data[n][:first_name],
                    last_name: data[n][:last_name])
      seed.issue.answer!
      seed.issue.approve! if n == 4
    end

    login_as compliance_admin_user
    click_link 'People'
    click_link 'Pending'
    click_link 'CSV'

    content = DownloadHelpers.download_content
    expect(content).to match(/pete\@test\.com.*\n.*frank\@test\.com.*\n.*mike\@test\.com.*\n.*jhon\@doe\.com/)
    expect(content).to match(/Peter,Clark.*\n.*Frank,Constanza.*\n.*Mike,Jhonson.*\n.*Jhon,Doe/)
    expect(content).to have_content('*', count: 4)
  end

  it 'shows pending people' do
    person = create(:empty_person)
    seed = create(:full_natural_docket_seed,
                  person: person,
                  issue: create(:basic_issue, reason: IssueReason.new_client),
                  first_name: 'Peter')
    seed.issue.complete!

    person2 = create(:empty_person)
    seed = create(:full_natural_docket_seed,
                  person: person2,
                  issue: create(:basic_issue, reason: IssueReason.new_client),
                  first_name: 'Jhon')
    seed.issue.observe!

    person3 = create(:empty_person)
    seed = create(:full_natural_docket_seed,
                  person: person3,
                  issue: create(:basic_issue, reason: IssueReason.new_client),
                  first_name: 'Gabriel')
    seed.issue.answer!

    20.times do
      person = create(:empty_person)
      create(:basic_issue, person: person)
    end

    login_as compliance_admin_user
    click_link 'People'
    click_link 'Pending'
    expect(page).to have_content('Peter')
    expect(page).to have_content('Jhon')
    expect(page).to have_content('Gabriel')
    expect(page).to have_content('Displaying all 3 People')
  end

  it 'shows only active issues for person' do
    person = create(:empty_person)
    issue1 = create(:basic_issue, person: person)
    create(:full_natural_docket_seed,
           person: person,
           issue: issue1,
           first_name: 'Michael',
           last_name: 'Jhonson')
    issue2 = create(:basic_issue, person: person)
    seed2 = create(:full_natural_docket_seed,
                   person: person,
                   issue: issue2,
                   first_name: 'Jake',
                   last_name: 'Jackson')
    login_as compliance_admin_user
    visit "people/#{person.id}"

    expect(page).to have_content('Jake Jackson')
    seed2.issue.reject!
    visit "people/#{person.id}"
    expect(page).to have_content('Michael Jhonson')
  end

  it 'loads and search for rejected people' do
    person = create :new_natural_person
    person.reject!
    person.reload

    login_as compliance_admin_user
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
