#encoding: utf-8
ActiveAdmin.register Issue, as: "Dashboard" do
  menu priority: 1

  actions :index

  scope :fresh, default: true
  scope :answered
  scope :draft
  scope :observed
  scope :abandoned
  scope :dismissed
  scope :all

  filter :created_at
  filter :updated_at
  filter :natural_docket_seed_first_name_or_natural_docket_seed_last_name_matches_any,
    label: "Natural Docket Seed"

  index title: '案 Issues Dashboard' do
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
