require 'rails_helper'

describe 'Dashboard' do
  let(:admin_user) { create(:admin_user) }

  describe 'group approval' do
    it 'shows success for every state' do
      login_as admin_user
      {
        approve:  'approved',
        complete: 'completed',
        dismiss:  'dismissed',
        reject:   'rejected',
        abandon:  'abandoned'
      }.each do |action, state|

        basic_issue = create(:basic_issue)
        basic_issue.complete!

        visit '/'
        find(:css, '#collection_selection_toggle_all').set(true)
        click_link 'Batch Action'
        click_link "#{action.capitalize} Selected"
        expect(page).to have_content("Issue #{basic_issue.id} #{state}")
        basic_issue.destroy
      end
    end

    it 'unauthorized user' do
      login_as create(:commercial_admin_user)
      issue = create(:basic_issue)
      issue.complete!
      visit '/'
      
      find(:css, '#collection_selection_toggle_all').set(true)
      click_link 'Batch Action'
      click_link 'Approve Selected'
      expect(page).to have_content('You are not authorized to perform this action.')
    end

    it 'shows issues approved, not all workflows has been performed, not allowed transition and not approve more than once' do
      login_as admin_user

      basic_issue = create(:basic_issue)
      basic_issue.complete!

      workflow_issue = create(:basic_issue)
      create(:basic_workflow, issue: workflow_issue)
      workflow_issue.complete!

      rejected_issue = create(:basic_issue)
      rejected_issue.reject!

      person = create(:new_natural_person, :with_new_client_reason) 
      approved_issue = person.issues.reload.last
      approved_issue.approve!

      visit '/'

      click_link 'All'

      find(:css, '#collection_selection_toggle_all').set(true)
      click_link 'Batch Action'
      click_link 'Approve Selected'
      expect(page).to have_content("Issue #{basic_issue.id} approved")
      expect(page).to have_content("Issue #{workflow_issue.id}: Event 'approve' cannot transition from 'new'. Failed callback(s): [:all_workflows_performed?]")
      expect(page).to have_content("Issue #{rejected_issue.id}: Event 'approve' cannot transition from 'rejected'.")
      expect(page).to have_content("Issue #{approved_issue.id}: no_more_updates_allowed")
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