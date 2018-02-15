ActiveAdmin.register DomicileSeed do
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
    permit_params :country, :state, :city, :street_address, :street_number, :postal_code, :floor, :apartment, :issue_id

    form do |f|
      f.inputs "Create new domicile seed" do
        f.input :issue, required: true
        f.input :country
        f.input :state
        f.input :city
        f.input :street_address
        f.input :street_number
        f.input :postal_code
        f.input :floor
        f.input :apartment
      end

      f.actions
    end
  end

  show do
    attributes_table do
      row :id
      row :created_at
      row :updated_at
      row :issue
      row :country
      row :state
      row :city
      row :street_address
      row :street_number
      row :postal_code
      row :floor
      row :apartment
    end 

    ArbreHelpers.attachments_panel(self, resource.attachments)
  end
end
