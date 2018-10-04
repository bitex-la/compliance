ActiveAdmin.register EventLog do
  actions :show, :index

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
