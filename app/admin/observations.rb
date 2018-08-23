ActiveAdmin.register Observation do
  menu priority: 2

  actions :all, :except => [:destroy]

  scope :admin_pending, default: true
  scope :all

  filter :observation_reason
  filter :scope, as: :select, collection: Observation.scopes
  filter :created_at
  filter :updated_at

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
  end
end

