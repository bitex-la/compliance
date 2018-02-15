ActiveAdmin.register QuotaSeed do
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
  begin
    permit_params :weight, :amount, :kind, :issue_id

    form do |f|
      f.inputs "Create new quota seed" do
        f.input :issue, required: true
        f.input :weight
        f.input :amount
        f.input :kind
      end
      f.actions
    end

    show do
      attributes_table do
        row :id
        row :created_at
        row :updated_at
        row :issue
        row :weight
        row :amount
        row :kind
      end

      ArbreHelpers.attachments_panel(self, resource.attachments)
    end
  end
end
