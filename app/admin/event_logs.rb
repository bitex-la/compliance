ActiveAdmin.register EventLog do
  menu priority: 7, if: -> { !current_admin_user.is_restricted }
  
  actions :show, :index

  filter :entity_id
  filter :entity_type
  filter :admin_user
  filter :verb
  filter :created_at

  index do
    selectable_column
    column :id
    column :entity_id
    column :entity_type
    column :verb do |e|
      EventLogKind.find(e.verb_id).name
    end
    column :created_at
    column :updated_at
    actions
  end
end
