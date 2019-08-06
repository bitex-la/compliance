ActiveAdmin.register Workflow do
  menu false

  actions :all, :except => [:index, :show, :new, :edit]

  scope :running, default: true
  scope :failing
  scope :all

  controller do
    def destroy
      issue = resource.issue
      resource.destroy
      redirect_to edit_person_issue_url(issue.person, issue)
    end
  end

  member_action :finish, method: :post do
    if !current_admin_user.is_restricted?
      resource.start! if resource.may_start?
      resource.finish! if resource.may_finish?
    else
      flash[:alert] = 'Only admins with full access can do this action'
    end
    redirect_to person_issue_path(resource.issue.person, resource.issue)
  end

  index do
    column(:id)
    column(:scope)
    column(:created_at)
    column(:updated_at)
    column(:issue)
  end
end