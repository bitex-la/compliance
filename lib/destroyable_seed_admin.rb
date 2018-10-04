class DestroyableSeedAdmin
  def self.register(klass)
    ActiveAdmin.register klass do
      menu false
      actions :destroy

      controller do
        def destroy
          issue = resource.issue
          resource.destroy
          redirect_to edit_person_issue_url(issue.person, issue)
        end
      end
    end
  end
end
