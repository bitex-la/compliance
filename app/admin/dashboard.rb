ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do

    tabs do
      tab :recent_issues do
        ArbreHelpers.issues_panel(self, Issue.just_created, 'Recent Issues')
      end

      tab :pending_for_review do
        ArbreHelpers.issues_panel(self, Issue.answered, 'Pending For Review')
      end

      tab :drafts do
        ArbreHelpers.issues_panel(self, Issue.incomplete, 'Drafts')
      end

      tab :observed do
        ArbreHelpers.issues_panel(self, Issue.observed, 'Observed Issues')
      end

      tab :observations_to_review do
        panel 'Observations to review' do
          table_for Observation.admin_pending do |o|
            o.column(:id) { |obv| obv.id }
            o.column(:note) { |obv| obv.note }
            o.column("observation reason") { |obv|
              unless obv.observation_reason.nil?
                obv.observation_reason.subject_en
              end
           }
           o.column(:created_at)
           o.column(:updated_at)
            o.column('Issue') { |obv|
              span link_to(obv.issue.id, person_issue_path(obv.issue.person, obv.issue))
            }
            o.column('Person') { |obv|
              span link_to(obv.issue.person.id, person_path(obv.issue.person))
            }
            o.column('Actions') { |obv|
              span link_to('View', person_issue_path(obv.issue.person, obv.issue))
            }
          end
        end
      end
    end
  end # content
end
