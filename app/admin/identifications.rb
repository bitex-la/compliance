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

menu false

show do 
  columns do
    column span: 3 do
      attributes_table do
        row :id
        row :created_at
        row :updated_at
        row :number
        row :identification_kind
        row :issuer
        row :person 
        row :public_registry_authority 
        row :public_registry_book
        row :public_registry_data
      end
    end
    column do 
      panel "Previous versions" do
        document_kind_id = identification.identification_kind_id
        previous_versions = 
          identification
          .person
          .identifications
          .where('replaced_by_id is not ? and identification_kind_id = ?', nil, document_kind_id)
          .order(created_at: :desc)
          .page(1).per(10)

        if previous_versions.any?
          table_for previous_versions.each do |i|
            i.column do |id|
              div(h4 id.name)
              div(span "Last modified at #{id.updated_at}")
              div(link_to 'View', identification_path(identification))
            end 
          end
        else
          span "0 Previous versions"
        end
      end
    end 
  end  
end

end
