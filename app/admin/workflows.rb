ActiveAdmin.register Workflow do
  menu false

  actions :all, :except => [:index, :show, :new, :edit]

  scope :running, default: true
  scope :failing
  scope :all

  controller do
    def destroy
      issue = resource.issue
      resource.tasks.map{|task| task.destroy}
      resource.destroy
      redirect_to edit_person_issue_url(issue.person, issue)
    end
  end

  index do
    column(:id)
    column(:scope)
    column(:created_at)
    column(:updated_at)
    column(:issue)
  end
end