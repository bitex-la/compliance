ActiveAdmin.register NaturalDocket do
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
    permit_params :first_name, :last_name, :birth_date, :nationality, :gender, :marital_status, :issue_id, :person_id, :replaced_by_id

    form do |f|
      f.inputs "Create new natural docket" do
        f.input :issue, required: true
        f.input :person, required: true
        f.input :replaced_by_id, label: 'replaced by', as: :select, collection: NaturalDocket.all.map{ |d| d.id }
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
