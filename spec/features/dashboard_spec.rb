require 'rails_helper'

describe 'Dashboard' do
  let(:admin_user) { create(:admin_user) }

  describe 'group approval' do
    describe 'errors' do
      it 'not all workflows has been performed' do
        login_as admin_user
        issue = create(:basic_issue)
        issue.complete!
        visit '/'

        find(:css, '#collection_selection_toggle_all').set(true)
        click_link 'Batch Action'
        click_link 'Approve Selected'
        expect(page).to have_content('Error')
      end
    end
  end

  describe 'priority' do
    it 'differentiates issues with priority bigger than zero' do
      login_as admin_user

      3.times do |n|
        create(:basic_issue, priority: n + 1)
      end

      4.times do
        create(:basic_issue)
      end

      visit '/'
      click_link 'All'

      expect(page).to have_selector(:css, '.top-priority', count: 3)

      indexes = Array.new(7) do |i|
        page.body.index("id=\"issue_#{i + 1}\"")
      end

      expect(indexes.sort).to eq([indexes[2],
        indexes[1],
        indexes[0],
        indexes[6],
        indexes[5],
        indexes[4],
        indexes[3]])
    end
  end

end