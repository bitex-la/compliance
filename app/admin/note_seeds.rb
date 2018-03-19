ActiveAdmin.register NoteSeed do
  menu false

  controller do
    def destroy
      issue = resource.issue
      resource.destroy
      redirect_to edit_issue_url(issue)
    end
  end
end
