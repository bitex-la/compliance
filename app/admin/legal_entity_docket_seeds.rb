ActiveAdmin.register LegalEntityDocketSeed do
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
    permit_params :industry, :business_description, :country, :commercial_name, :legal_name, :issue_id

    form do |f|
      f.inputs "Create new legal entity docket seed" do
        f.input :issue, required: true
        f.input :industry
        f.input :business_description
        f.input :country
        f.input :commercial_name
        f.input :legal_name
      end
      f.actions
    end
  end
end
