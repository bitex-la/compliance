ActiveAdmin.register AllowanceSeed do
  menu false

  controller do
    def destroy
      issue = resource.issue
      resource.destroy
      redirect_to edit_person_issue_url(issue.person, issue)
    end
  end
end
