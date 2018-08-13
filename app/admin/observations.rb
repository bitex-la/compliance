ActiveAdmin.register Observation do
  actions :all, :except => [:destroy]

  scope :admin_pending, default: true
  scope :all

  index do
    column(:id)
    column(:note)
    column("observation reason") { |obv|
      obv.observation_reason.try(:subject_en)
    }
    column(:created_at)
    column(:updated_at)
    column(:issue)
    column(:person){|o| o.issue.person }
    actions
  end
end

