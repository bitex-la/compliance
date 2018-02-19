ActiveAdmin.register Domicile do
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
    permit_params :country, :state, :city, :street_address, :street_number, :postal_code, :floor, :apartment, :issue_id, :person_id, :replaced_by_id

    form do |f|
      f.inputs "Create new domicile" do
        f.input :issue, required: true
        f.input :person, required: true    
        f.input :replaced_by_id, label: 'replaced by', as: :select, collection: Domicile.all.map{ |d| d.id }
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

end
