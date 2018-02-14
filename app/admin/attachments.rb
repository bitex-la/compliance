ActiveAdmin.register Attachment do
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
  permit_params :document, :person_id

  form do |f|
    f.inputs "Upload" do
      f.input :person
      f.input :document, required: true, as: :file
    end
    f.actions
  end
end
  
end
