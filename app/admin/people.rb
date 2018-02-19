ActiveAdmin.register Person do
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

  show do
    attributes_table do
      row :id
      row :created_at
      row :updated_at
    end
    
    if person.natural_dockets.any?
      panel 'Natural Docket' do
        table_for NaturalDocket.current(person) do |n|
          n.column("ID") do |docket|
            link_to(docket.id, natural_docket_path(docket))
          end
          n.column("First Name")      { |docket| docket.first_name }
          n.column("Last Name")       { |docket| docket.last_name }
          n.column("Birthdate")       { |docket| docket.birth_date }
          n.column("Nationality")     { |docket| docket.nationality }
          n.column("Gender")          { |docket| docket.gender }
          n.column("Marital Status")  { |docket| docket.marital_status }
          n.column("Attachments") do |docket|
            docket.attachments
              .map{|a| link_to a.document_file_name, a.document.url, target: '_blank'}
              .join("<br />").html_safe
          end
          n.column("") { |docket|
            link_to("View", natural_docket_path(docket))
          }
          n.column("") { |docket|
            link_to("Edit", edit_natural_docket_path(docket))
          }
        end
      end
    end
  
    if person.legal_entity_dockets.any?
      panel 'Legal Entity Docket' do
        
      end
    end
  
    if person.identifications.any?
      panel 'Identification' do
        
      end
    end
  
    if person.domiciles.any?
      panel 'Domiciles' do
        
      end
    end
  
    if person.quotas.any?
      panel 'Quotas' do
        
      end
    end
  end
end
