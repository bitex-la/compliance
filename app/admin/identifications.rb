ActiveAdmin.register Identification do
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
  permit_params :kind, :number, :issuer, :issue_id, :person_id, :replaced_by_id

  form do |f|
    f.inputs "Create new identification" do
      f.input :issue,  required: true
      f.input :person, required: true
      f.input :replaced_by_id, label: 'replaced by', as: :select, collection: Identification.all.map{ |d| d.id }
      f.input :kind
      f.input :number
      f.input :issuer
    end
    f.actions
  end
end

end
