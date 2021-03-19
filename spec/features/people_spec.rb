require 'rails_helper'

describe 'people' do
  describe 'pending scope' do
    let(:admin_user) { create(:admin_user) }

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

      login_as admin_user
      click_link 'People'
      click_link 'Pending'
      expect(page).to have_content('Peter')
      expect(page).to have_content('Jhon')
      expect(page).to have_content('Gabriel')
      expect(page).to have_content('Displaying all 3 People')
    end
  end
end
