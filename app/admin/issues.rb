ActiveAdmin.register Issue do
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
      row :person
    end 

    if issue.legal_entity_docket_seeds.count > 0
      panel 'legal entity dockets' do
        table_for issue.legal_entity_docket_seeds do |l|
          l.column("ID") do |seed|
            link_to(seed.id, admin_legal_entity_docket_seed_path(seed))
          end
          l.column("Industry")             { |seed| seed.industry }
          l.column("Business Description") { |seed| seed.business_description }
          l.column("Country")              { |seed| seed.country }
          l.column("Commercial Name")      { |seed| seed.commercial_name }
          l.column("Legal Name")           { |seed| seed.legal_name }
          l.column("") { |seed|
            link_to("View", admin_legal_entity_docket_seed_path(seed))
          }
          l.column("") { |seed|
            link_to("Edit", edit_admin_legal_entity_docket_seed_path(seed))
          }
        end
      end
    end

    if issue.natural_docket_seeds.count > 0
      panel 'natural dockets' do
        table_for issue.natural_docket_seeds do |n|
          n.column("ID") do |seed|
            link_to(seed.id, admin_natural_docket_seed_path(seed))
          end
          n.column("First Name")      { |seed| seed.first_name }
          n.column("Last Name")       { |seed| seed.last_name }
          n.column("Birthdate")       { |seed| seed.birth_date }
          n.column("Nationality")     { |seed| seed.nationality }
          n.column("Gender")          { |seed| seed.gender }
          n.column("Marital Status")  { |seed| seed.marital_status }
          n.column("") { |seed|
            link_to("View", admin_natural_docket_seed_path(seed))
          }
          n.column("") { |seed|
            link_to("Edit", edit_admin_natural_docket_seed_path(seed))
          }
        end
      end
    end

    if issue.quota_seeds.count > 0
      panel 'Quotas' do
        table_for issue.quota_seeds do |q|
          q.column("ID") do |seed|
            link_to(seed.id, admin_quota_seed_path(seed))
          end
          q.column("Weight") { |seed| seed.weight }
          q.column("Amount") { |seed| seed.amount }
          q.column("Kind")   { |seed| seed.kind }
          q.column("") { |seed|
            link_to("View", admin_quota_seed_path(seed))
          }
          q.column("") { |seed|
            link_to("Edit", edit_admin_quota_seed_path(seed))
          }
        end
      end
    end

    if issue.domicile_seeds.count > 0
      panel 'domiciles' do
        table_for issue.domicile_seeds do |d|
          d.column("ID") do |seed|
            link_to(seed.id, admin_domicile_seed_path(seed))
          end
          d.column("Country")         { |seed| seed.country }
          d.column("State")           { |seed| seed.state }
          d.column("City")            { |seed| seed.city }
          d.column("Street Address")  { |seed| seed.street_address }
          d.column("Street Number")   { |seed| seed.street_number }
          d.column("Postal Code")     { |seed| seed.postal_code }
          d.column("Floor")           { |seed| seed.floor}
          d.column("Apartment")       { |seed| seed.apartment }
          d.column("Attachments") do |seed|
            seed.attachments
              .map{|a| link_to a.document_file_name, a.document.url, target: '_blank'}
              .join("<br />").html_safe
          end
          d.column("") { |seed|
            link_to("View", admin_domicile_seed_path(seed))
          }
          d.column("") { |seed|
            link_to("Edit", edit_admin_domicile_seed_path(seed))
          }
        end
      end
    end

    if issue.identification_seeds.count > 0
      panel 'Identifications' do
        table_for issue.identification_seeds do |i|
          i.column("ID") do |seed|
            link_to(seed.id, admin_identification_seed_path(seed))
          end
          i.column("Kind")    { |seed| seed.kind }
          i.column("Number")  { |seed| seed.number }
          i.column("Issuer")  { |seed| seed.issuer }
          i.column("") { |seed|
            link_to("View", admin_identification_seed_path(seed))
          }
          i.column("") { |seed|
            link_to("Edit", edit_admin_identification_seed_path(seed))
          }
        end
      end
    end
  end
end
