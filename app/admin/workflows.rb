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

    def related_person
      resource.issue.person.id
    end
  end

  member_action :finish, method: :post do  
    authorize!(:finish, resource)
  
    resource.start! if resource.may_start?
    resource.finish! if resource.may_finish?
    
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