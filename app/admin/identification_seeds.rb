ActiveAdmin.register IdentificationSeed do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end
menu false

  begin
    permit_params :kind, :number, :issuer, :issue_id

    form do |f|
      f.inputs "Create new identification seed" do
        f.input :issue, required: true
        f.input :kind
        f.input :number
        f.input :issuer
      end
      f.actions
    end

    show do
      attributes_table do
        row :id
        row :created_at
        row :updated_at
        row :issue
        row :kind
        row :number
        row :issuer
      end

      ArbreHelpers.attachments_panel(self, resource.attachments)
    end   
  end
end
