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
end