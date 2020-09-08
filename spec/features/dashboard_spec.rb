require 'rails_helper'

describe 'Dashboard' do
  describe 'group approval' do
    describe 'errors' do
      it 'not all workflows has been performed' do
        issue = create(:basic_issue)
        issue.complete!
        visit '/'

        find(:css, '#collection_selection_toggle_all').set(true)
        click_link 'Batch Action'
        click_link 'Approve Selected'
      end
    end
  end
end