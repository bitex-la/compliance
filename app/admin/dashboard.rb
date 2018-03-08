ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do
    columns do
      column do
        ArbreHelpers.issues_panel(self, Issue.just_created, 'Recent Issues')
        ArbreHelpers.issues_panel(self, Issue.answered, 'Pending for review')
      end
      column do
        panel 'Observations to review' do
          table_for Observation.admin_pending do |o|
            o.column(:id) { |obv| obv.id }
            o.column(:note) { |obv| obv.note }
            o.column(:observation_reason) { |obv| 
              obv.observation_reason.subject
            }
            o.column('Person') { |obv|
              span link_to(obv.issue.person.id, people_path(obv.issue.person))
            }
            o.column('Actions') { |obv|
              span link_to('View', issue_path(obv.issue))
            }
          end
        end
      end
    end
  end # content
end
