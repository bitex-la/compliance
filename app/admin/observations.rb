ActiveAdmin.register Observation do
  menu priority: 2

  actions :all, :except => [:destroy, :new]

  scope :admin_pending, default: true
  scope :robot_pending
  scope :client_pending
  scope :all

  filter :observation_reason
  filter :scope, as: :select, collection: Observation.scopes
  filter :by_issue_reason, as: :select, collection: IssueReason.all
  filter :created_at
  filter :updated_at

  controller do
    def related_person
      resource.issue.person.id
    end
  end

  index do
    column "" do |o|
      strong o.name
      br
      if o.note.presence
        span o.note
        br
      end
      strong "Reply:"
      span o.reply
    end
    column(:scope)
    column(:created_at)
    column(:updated_at)
    column(:issue)
    column "Person" do |o|
      link_to o.issue.person.person_info, o.issue.person
    end
  end
end

