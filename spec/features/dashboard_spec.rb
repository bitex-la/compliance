# frozen_string_literal: true

require 'rails_helper'

ActiveAdmin.register Issue, sort_order: :priority_desc, as: 'Dashboard' do
  batch_action :testing_with_authorize do |ids, _inputs|
    authorize!(:approve, Issue)
    Issue.find(ids).first.approve!
  end

  batch_action :testing_without_authorize do |ids, _inputs|
    flash[:notice] = 'Does not enforce authorization'
    Issue.find(ids).first.approve!
    redirect_to dashboards_url
  end
end

describe 'Dashboard' do
  let(:admin_user) { create(:admin_user) }

  describe 'group approval' do
    it 'shows success for every state' do
      login_as admin_user
      {
        approve: 'approved',
        complete: 'completed',
        dismiss: 'dismissed',
        reject: 'rejected',
        abandon: 'abandoned'
      }.each do |action, state|

        issues = 10.times.map do
          issue = create(:basic_issue)
          issue.complete!
          issue
        end

        visit '/'
        find(:css, '#collection_selection_toggle_all').set(true)
        click_link 'Batch Action'
        click_link "#{action.capitalize} Selected"
        issues.each do |issue|
          expect(page).to have_content("Issue #{issue.id} #{state}")
        end
        issues.map(&:destroy)
      end
    end

    it 'operations user can only see the authorized action (Complete)' do
      login_as create(:operations_admin_user)
      basic_issue = create(:basic_issue)
      visit '/'

      click_link 'All'
      find(:css, '#collection_selection_toggle_all').set(true)
      click_link 'Batch Action'
      expect(page).not_to have_content('Approve Selected')
      expect(page).to have_content('Complete Selected')
      click_link 'Complete Selected'
      expect(page).to have_content("Issue #{basic_issue.id} completed")
    end

    it 'unauthorized user can not approve issue' do
      login_as create(:operations_admin_user)

      basic_issue = create(:basic_issue)
      basic_issue.complete!

      visit '/'
      find(:css, '#collection_selection_toggle_all').set(true)
      click_link 'Batch Action'
      click_link 'Testing With Authorize Selected'
      expect(page).to have_content('You are not authorized to perform this action.')
      expect(basic_issue.reload.approved?).to be_falsy

      find(:css, '#collection_selection_toggle_all').set(true)
      click_link 'Batch Action'
      click_link 'Testing Without Authorize Selected'
      expect(page).to have_content('Does not enforce authorization')
      expect(basic_issue.reload.approved?).to be_truthy
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

  describe 'functionality' do
    before(:each) do
      login_as admin_user

      9.times do |n|
        issue = create(:basic_issue)
        nationality =
          if n < 4
            'AR'
          else
            'ES'
          end
        create :full_natural_docket_seed, issue: issue, nationality: nationality
      end

      visit '/'
      click_link 'All'
    end

    it 'argentina returns 4 results' do
      fill_in :q_natural_docket_seed_nationality_eq, with: 'argentina'

      within '.ui-menu-item' do
        find('.ui-menu-item-wrapper').click
      end
      click_on 'Filter'

      expect(page).to have_content('Displaying all 4 Dashboards')
    end

    it 'spain returns 5 results' do
      fill_in :q_natural_docket_seed_nationality_eq, with: 'spain'

      within '.ui-menu-item' do
        find('.ui-menu-item-wrapper').click
      end
      click_on 'Filter'

      expect(page).to have_content('Displaying all 5 Dashboards')
    end
  end

  describe 'filter and ordering by tpi' do
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
      login_as admin_user
      visit '/'
      click_link 'All'
    end

    context 'when having multiple people with tpi' do
      it 'it filters by tpi' do
        find('#q_person_tpi_input').click
        within '.select2-results__options' do
          find('li', text: 'usd_20001_to_50000').click
        end
        click_on 'Filter'

        expect(page.find('tbody').find('tr:nth-child(1)')).to have_content 'usd_20001_to_50000'

        find('#q_person_tpi_input').click
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
  end
end
