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
end
