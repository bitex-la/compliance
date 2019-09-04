ActiveAdmin.register ObservationReason do
  menu priority: 4, if: -> { !current_admin_user.is_restricted? }
  actions :all, except: :destroy

  index do
    column :id
    column :scope
    column :subject_en
    column :body_en
    column :subject_es
    column :body_es
    column :subject_pt
    column :body_pt
    column :created_at
    column :updated_at
    actions
  end
end
