ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do
    # div class: "blank_slate_container", id: "dashboard_default_message" do
    #   span class: "blank_slate" do
    #     span I18n.t("active_admin.dashboard_welcome.welcome")
    #     small I18n.t("active_admin.dashboard_welcome.call_to_action")
    #   end
    # end

    columns do
      column do
        panel "Recent Issues" do
          table_for Issue.recent(1, 10) do |i|
            i.column("ID") { |issue|
              link_to(issue.id, issue_path(issue)) 
            }
            i.column("Person") { |issue|
              link_to(issue.person.id, person_path(issue.person)) 
            }
            i.column("Created at") { |issue|
              issue.created_at 
            }
            i.column("Updated at") { |issue|
              issue.updated_at 
            }
            i.column("Actions") { |issue|
              span link_to("View", issue_path(issue))
              span link_to("Edit", edit_issue_path(issue))
            }
          end
        end
      end
    end

    # Here is an example of a simple dashboard with columns and panels.
    #
    # columns do
    #   column do
    #     panel "Recent Posts" do
    #       ul do
    #         Post.recent(5).map do |post|
    #           li link_to(post.title, post_path(post))
    #         end
    #       end
    #     end
    #   end

    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end
  end # content
end
