ActiveAdmin.register EventLog do
  actions :all, except: [:destroy, :edit]

  index do
    selectable_column
    column :id
    column :entity_id
    column :entity_type
    column :verb
    column :created_at
    column :updated_at
    actions
  end
end
