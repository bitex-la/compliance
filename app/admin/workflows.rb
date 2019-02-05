ActiveAdmin.register Workflow do
  menu priority: 3

  actions :all, :except => [:destroy]

  scope :running, default: true
  scope :failing
  scope :all

  index do
    column(:id)
    column(:scope)
    column(:created_at)
    column(:updated_at)
    column(:issue)
  end
end