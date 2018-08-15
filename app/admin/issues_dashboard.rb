#encoding: utf-8
ActiveAdmin.register Issue, as: "Dashboard" do
  menu priority: 1

  actions :index

  scope :just_created, default: true
  scope :answered
  scope :answered
  scope :incomplete
  scope :observed
  scope :abandoned
  scope :dismissed
  scope :all

  filter :aasm_state
  filter :created_at
  filter :updated_at

  index do
    column(:id)  do |o|
      link_to o.id, [o.person, o]
    end
    column(:person) do |o|
      link_to o.person.person_email, o.person
    end
    column(:person_enabled)do |o|
      o.person.enabled
    end
    column(:state)
    column(:created_at)
    column(:updated_at)
  end
end
