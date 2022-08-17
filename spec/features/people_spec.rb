# frozen_string_literal: true

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

  context 'when having multiple people with tpi' do
    before(:each) do
      person1 = create(:empty_person,
                       tpi: 'usd_20001_to_50000')
      issue1 = create(:basic_issue, person: person1)
      create(:full_natural_docket_seed,
             person: person1,
             issue: issue1,
             first_name: 'Michael',
             last_name: 'Jhonson')
      person2 = create(:empty_person,
                       tpi: 'usd_5001_to_10000')
      issue2 = create(:basic_issue, person: person2)
      create(:full_natural_docket_seed,
             person: person2,
             issue: issue2,
             first_name: 'John',
             last_name: 'Doe')
      login_as compliance_admin_user
      visit 'people'
    end

    it 'it filters by tpi' do
      find('#q_tpi_input').click
      within '.select2-results__options' do
        find('li', text: 'usd_20001_to_50000').click
      end
      click_on 'Filter'

      expect(page.find('tbody').find('tr:nth-child(1)')).to have_content 'usd_20001_to_50000'

      find('#q_tpi_input').click
      within '.select2-results__options' do
        find('li', text: 'usd_5001_to_10000').click
      end
      click_on 'Filter'

      expect(page.find('tbody').find('tr:nth-child(1)')).to have_content 'usd_5001_to_10000'
      expect(page.find('tbody').find('tr:nth-child(1)')).to have_no_content 'usd_20001_to_50000'
    end

    it 'it sorts them by tpi' do
      visit 'dashboards'
      click_link 'All'
      click_link 'Tpi'
      expect(page.find('tbody').find('tr:nth-child(1)')).to have_content 'usd_20001_to_50000'
      click_link 'Tpi'
      expect(page.find('tbody').find('tr:nth-child(1)')).to have_content 'usd_5001_to_10000'
    end
  end

  it 'renders correctly people thats related to others with a not common tag' do
    argentina_tag = create(:base_person_tag, tag_type: :person, name: 'active-in-AR')
    chile_tag = create(:base_person_tag, tag_type: :person, name: 'active-in-CL')
    argentina_person = create(:full_natural_person, tags: [argentina_tag], country: 'AR')
                         .tap(&:reload)
                         .tap { |p| p.natural_docket.update!(first_name: 'Ricardo', last_name: 'Molina') }
    chile_person = create(:full_natural_person, tags: [chile_tag], country: 'CL')
                     .tap(&:reload)
                     .tap { |p| p.natural_docket.update!(first_name: 'Pablito', last_name: 'Ruiz') }

    argentina_person.affinities.create!(person: argentina_person,
                                        affinity_kind: AffinityKind.payer,
                                        related_person: chile_person)
    compliance_admin_user.update!(tags: [argentina_tag])

    login_as compliance_admin_user
    visit "people/#{argentina_person.id}"

    expect(page).to have_content('Ricardo Molina')
  end
end
