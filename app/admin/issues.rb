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

  actions :all, :except => :destroy

  action_item :approve, only: :show do
    link_to 'Approve', '/'
  end

  action_item :add_observation, only: :show do
    link_to 'Add Observation', '/'
  end

  form do |f|
    if f.object.persisted?
      f.inputs 'Basics' do
        f.input :person_id
      end
    end

    ArbreHelpers.has_one_form self, f, "Identification", :identification_seed do |idf|
      idf.input :number
      idf.input :kind
      idf.input :issuer
      ArbreHelpers.has_many_form self, idf, :attachments do |af|
        af.input :document, as: :file, label: "File", hint: af.object.document.nil? ? af.template.content_tag(:span, "No File Yet") : af.template.link_to('click to enlarge', af.object.document.url, target: '_blank')
        af.input :_destroy, as: :boolean, required: false, label: 'Remove image'
      end
    end

    ArbreHelpers.has_one_form self, f, "Domicile", :domicile_seed do |df|
      df.input :country
      df.input :state
      df.input :city
      df.input :street_address
      df.input :street_number
      df.input :postal_code
      df.input :floor
      df.input :apartment
      ArbreHelpers.has_many_form self, df, :attachments do |af|
        af.input :document, as: :file, label: "File", hint: af.object.document.nil? ? af.template.content_tag(:span, "No File Yet") : af.template.link_to('click to enlarge', af.object.document.url, target: '_blank')
        af.input :_destroy, as: :boolean, required: false, label: 'Remove image'
      end
    end 
    
    ArbreHelpers.has_one_form self, f, "Natural Docket", :natural_docket_seed do |nf|
      nf.input :first_name
      nf.input :last_name
      nf.input :birth_date, start_year: 1900
      nf.input :nationality
      nf.input :gender
      nf.input :marital_status
      ArbreHelpers.has_many_form self, nf, :attachments do |af|
        af.input :document, as: :file, label: "File", hint: af.object.document.nil? ? af.template.content_tag(:span, "No File Yet") : af.template.link_to('click to enlarge', af.object.document.url, target: '_blank')
        af.input :_destroy, as: :boolean, required: false, label: 'Remove image'
      end
    end

    ArbreHelpers.has_one_form self, f, "Legal Entity Docket", :legal_entity_docket_seed do |lf|
      lf.input :industry
      lf.input :business_description
      lf.input :country
      lf.input :commercial_name
      lf.input :legal_name
      ArbreHelpers.has_many_form self, lf, :attachments do |af|
        af.input :document, as: :file, label: "File", hint: af.object.document.nil? ? af.template.content_tag(:span, "No File Yet") : af.template.link_to('click to enlarge', af.object.document.url, target: '_blank')
        af.input :_destroy, as: :boolean, required: false, label: 'Remove image'
      end
    end

    ArbreHelpers.has_many_form self, f, :allowance_seeds do |qf, context|
      qf.input :weight 
      qf.input :amount
      qf.input :kind
      ArbreHelpers.has_many_form context, qf, :attachments do |af|
        af.input :document, as: :file, label: "File", hint: af.object.document.nil? ? af.template.content_tag(:span, "No File Yet") : af.template.link_to('click to enlarge', af.object.document.url, target: '_blank')
        af.input :_destroy, as: :boolean, required: false, label: 'Remove image'
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

    if issue.legal_entity_docket_seed.present?
      panel 'legal entity dockets' do
        table_for issue.legal_entity_docket_seed do |l|
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

    if issue.natural_docket_seed.present?
      panel 'natural dockets' do
        table_for issue.natural_docket_seed do |n|
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

    if issue.allowance_seeds.any?
      panel 'Allowances' do
        table_for issue.allowance_seeds do |q|
          q.column("ID") do |seed|
            link_to(seed.id, allowance_seed_path(seed))
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
            link_to("View", allowance_seed_path(seed))
          }
          q.column("") { |seed|
            link_to("Edit", edit_allowance_seed_path(seed))
          }
        end
      end
    end

    if issue.domicile_seed.present?
      panel 'domiciles' do
        table_for issue.domicile_seed do |d|
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

    if issue.identification_seed.present?
      panel 'Identifications' do
        table_for issue.identification_seed do |i|
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
