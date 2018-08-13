#encoding: utf-8
ActiveAdmin.register Issue, as: "Dashboard" do
  actions :index

  scope :just_created, default: true
  scope :answered
  scope :answered
  scope :incomplete
  scope :observed
  scope :abandoned
  scope :dismissed
  scope :all

  filter :state
  filter :created_at
  filter :updated_at

  index do
    column(:id)  do |o|
      link_to o.id, [:admin, :issues, o.id] 
    end
    column(:person) do |o|
      link_to o.person.person_email, [:admin, :people, o.person_id] 
    end
    column(:person_enabled)do |o|
      o.person.enabled
    end
    column(:state)
    column(:created_at)
    column(:updated_at)
  end
end
