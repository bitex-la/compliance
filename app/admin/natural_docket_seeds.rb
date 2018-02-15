ActiveAdmin.register NaturalDocketSeed do
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
    permit_params :first_name, :last_name, :birth_date, :nationality, :gender, :marital_status, :issue_id

    form do |f|
      f.inputs "Create new natural docket seed" do
        f.input :issue, required: true
        f.input :first_name
        f.input :last_name
        f.input :birth_date
        f.input :nationality
        f.input :gender
        f.input :marital_status
      end
      f.actions
    end
  end
end
