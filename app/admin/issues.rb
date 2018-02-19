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
# permit_params :country, :state, :city, :street_address, :street_number, :postal_code, :floor, :apartment, :issue_id
  #
  form do |f|
    if f.object.persisted?
      f.inputs 'Basics' do
        f.input :person_id
      end
    end

    f.has_many :domicile_seeds do |df|
      df.inputs "Create new domicile seed" do
        df.input :country
        df.input :state
        df.input :city
        df.input :street_address
        df.input :street_number
        df.input :postal_code
        df.input :floor
        df.input :apartment
      end

      if df.object.try(:persisted?)
        span link_to 'Show', df.object
      end
    end

    f.actions
  end

  show do
    attributes_table do
      row :id
      row :created_at
      row :updated_at
      row :person
    end 

    if issue.legal_entity_docket_seeds.any?
      panel 'legal entity dockets' do
        table_for issue.legal_entity_docket_seeds do |l|
          l.column("ID") do |seed|
            link_to(seed.id, legal_entity_docket_seed_path(seed))
          end
          l.column("Industry")             { |seed| seed.industry }
          l.column("Business Description") { |seed| seed.business_description }
          l.column("Country")              { |seed| seed.country }
          l.column("Commercial Name")      { |seed| seed.commercial_name }
          l.column("Legal Name")           { |seed| seed.legal_name }
          l.column("Attachments") do |seed|
            seed.attachments
              .map{|a| link_to a.document_file_name, a.document.url, target: '_blank'}
              .join("<br />").html_safe
          end
          l.column("") { |seed|
            link_to("View", legal_entity_docket_seed_path(seed))
          }
          l.column("") { |seed|
            link_to("Edit", edit_legal_entity_docket_seed_path(seed))
          }
        end
      end
    end

    if issue.natural_docket_seeds.any?
      panel 'natural dockets' do
        table_for issue.natural_docket_seeds do |n|
          n.column("ID") do |seed|
            link_to(seed.id, natural_docket_seed_path(seed))
          end
          n.column("First Name")      { |seed| seed.first_name }
          n.column("Last Name")       { |seed| seed.last_name }
          n.column("Birthdate")       { |seed| seed.birth_date }
          n.column("Nationality")     { |seed| seed.nationality }
          n.column("Gender")          { |seed| seed.gender }
          n.column("Marital Status")  { |seed| seed.marital_status }
          n.column("Attachments") do |seed|
            seed.attachments
              .map{|a| link_to a.document_file_name, a.document.url, target: '_blank'}
              .join("<br />").html_safe
          end
          n.column("") { |seed|
            link_to("View", natural_docket_seed_path(seed))
          }
          n.column("") { |seed|
            link_to("Edit", edit_natural_docket_seed_path(seed))
          }
        end
      end
    end

    if issue.quota_seeds.any?
      panel 'Quotas' do
        table_for issue.quota_seeds do |q|
          q.column("ID") do |seed|
            link_to(seed.id, quota_seed_path(seed))
          end
          q.column("Weight") { |seed| seed.weight }
          q.column("Amount") { |seed| seed.amount }
          q.column("Kind")   { |seed| seed.kind }
          q.column("Attachments") do |seed|
            seed.attachments
              .map{|a| link_to a.document_file_name, a.document.url, target: '_blank'}
              .join("<br />").html_safe
          end
          q.column("") { |seed|
            link_to("View", quota_seed_path(seed))
          }
          q.column("") { |seed|
            link_to("Edit", edit_quota_seed_path(seed))
          }
        end
      end
    end

    if issue.domicile_seeds.any?
      panel 'domiciles' do
        table_for issue.domicile_seeds do |d|
          d.column("ID") do |seed|
            link_to(seed.id, domicile_seed_path(seed))
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
            link_to("View", domicile_seed_path(seed))
          }
          d.column("") { |seed|
            link_to("Edit", edit_domicile_seed_path(seed))
          }
        end
      end
    end

    if issue.identification_seeds.any?
      panel 'Identifications' do
        table_for issue.identification_seeds do |i|
          i.column("ID") do |seed|
            link_to(seed.id, identification_seed_path(seed))
          end
          i.column("Kind")    { |seed| seed.kind }
          i.column("Number")  { |seed| seed.number }
          i.column("Issuer")  { |seed| seed.issuer }
          i.column("Attachments") do |seed|
            seed.attachments
              .map{|a| link_to a.document_file_name, a.document.url, target: '_blank'}
              .join("<br />").html_safe
          end
          i.column("") { |seed|
            link_to("View", identification_seed_path(seed))
          }
          i.column("") { |seed|
            link_to("Edit", edit_identification_seed_path(seed))
          }
        end
      end
    end
  end
end
