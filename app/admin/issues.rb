ActiveAdmin.register Issue do
  actions :all, :except => :destroy

  config.clear_action_items!
  action_item only: [:index] do
    link_to 'New', new_issue_path
  end

  %i(approve abandon reject dismiss).each do |action|
    action_item action, only: :edit, if: lambda { resource.send("may_#{action}?") } do
      link_to action.to_s.titleize, [action, :issue], method: :post
    end

    member_action action, method: :post do
      resource.send("#{action}!")
      redirect_to action: :show
    end
  end

  controller do
    def edit
      @page_title = resource.name
      return redirect_to issue_url unless resource.editable?
      super
    end

    def show
      return redirect_to edit_issue_url if resource.editable?
      super
    end
  end

  form do |f|
    if f.object.persisted?
      f.inputs 'Basics' do
        f.input :person_id
      end
    else
      f.inputs 'Select a person' do
        f.input :person_id, as: :select, collection: Person.all
      end
    end

    ArbreHelpers.has_many_form self, f, :identification_seeds do |sf, context|
      sf.input :number
      sf.input :kind
      sf.input :issuer
      sf.input :replaces
      ArbreHelpers.has_many_attachments(context, sf)
    end

    ArbreHelpers.has_many_form self, f, :domicile_seeds do |sf, context|
      sf.input :country
      sf.input :state
      sf.input :city
      sf.input :street_address
      sf.input :street_number
      sf.input :postal_code
      sf.input :floor
      sf.input :apartment
      sf.input :replaces
      ArbreHelpers.has_many_attachments(context, sf)
    end 
    
    ArbreHelpers.has_one_form self, f, "Natural Docket", :natural_docket_seed do |sf|
      sf.input :first_name
      sf.input :last_name
      sf.input :birth_date, start_year: 1900
      sf.input :nationality, as: :country
      sf.input :gender, collection: ['Male', 'Female']
      sf.input :marital_status, collection: ['Single', 'Married', 'Divorced']
      ArbreHelpers.has_many_attachments(self, sf)
    end

    ArbreHelpers.has_one_form self, f, "Legal Entity Docket", :legal_entity_docket_seed do |sf|
      sf.input :industry
      sf.input :business_description
      sf.input :country
      sf.input :commercial_name
      sf.input :legal_name
      ArbreHelpers.has_many_attachments(self, sf)
    end

    ArbreHelpers.has_one_form self, f, "Argentina Invoicing Detail", :argentina_invoicing_detail_seed do |af|
      af.input :vat_status_id
      af.input :tax_id
    end

    ArbreHelpers.has_many_form self, f, :allowance_seeds do |sf, context|
      sf.input :weight 
      sf.input :amount
      sf.input :kind
      sf.input :replaces
      ArbreHelpers.has_many_attachments(context, sf)
    end

    ArbreHelpers.has_many_form self, f, :phone_seeds do |pf, context|
      pf.input :number
      pf.input :kind
      pf.input :country
      pf.input :replaces
      pf.input :has_whatsapp
      pf.input :has_telegram
      pf.input :note
      ArbreHelpers.has_many_attachments(context, pf)
    end  

    ArbreHelpers.has_many_form self, f, :email_seeds do |ef, context|
      ef.input :address
      ef.input :kind
      ArbreHelpers.has_many_attachments(context, ef)
    end 

    ArbreHelpers.has_many_form self, f, :observations do |sf|
      sf.input :observation_reason
      sf.input :scope
      sf.input :note
      sf.input :reply
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
      panel 'legal entity docket seed' do
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
      panel 'natural docket seed' do
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

    if issue.argentina_invoicing_detail_seed.present?
      panel 'argentina invoicing details seed' do
        table_for issue.argentina_invoicing_detail_seed do |n|
          n.column("ID") do |seed|
            link_to(seed.id, argentina_invoicing_detail_seed_path(seed))
          end
          n.column("VAT status id")      { |seed| seed.vat_status_id }
          n.column("Tax ID")       { |seed| seed.tax_id }
          n.column("Attachments") do |seed|
            seed.attachments
              .map{|a| link_to a.document_file_name, a.document.url, target: '_blank'}
              .join("<br />").html_safe
          end
          n.column("") { |seed|
            link_to("View", argentina_invoicing_detail_seed_path(seed))
          }
          n.column("") { |seed|
            link_to("Edit", argentina_invoicing_detail_seed_path(seed))
          }
        end
      end
    end

    if issue.allowance_seeds.any?
      panel 'Allowance seeds' do
        table_for issue.allowance_seeds do |q|
          q.column("ID") do |seed|
            link_to(seed.id, allowance_seeds_path(seed))
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
            link_to("View", allowance_seeds_path(seed))
          }
          q.column("") { |seed|
            link_to("Edit", edit_allowance_seed_path(seed))
          }
        end
      end
    end

    if issue.domicile_seeds.any?
      panel 'Domicile seed' do
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
      panel 'Identification seed' do
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

    if issue.email_seeds.any?
      panel 'Email seeds' do
        table_for issue.email_seeds do |i|
          i.column("ID") do |seed|
            link_to(seed.id, email_seed_path(seed))
          end
          i.column("Kind")    { |seed| seed.kind }
          i.column("Address")  { |seed| seed.address }
          i.column("Attachments") do |seed|
            seed.attachments
              .map{|a| link_to a.document_file_name, a.document.url, target: '_blank'}
              .join("<br />").html_safe
          end
          i.column("") { |seed|
            link_to("View", email_seed_path(seed))
          }
          i.column("") { |seed|
            link_to("Edit", edit_email_seed_path(seed))
          }
        end
      end
    end


    if issue.phone_seeds.any?
      panel 'Phone seeds' do
        table_for issue.phone_seeds do |i|
          i.column("ID") do |seed|
            link_to(seed.id, phone_seed_path(seed))
          end
          i.column("Kind")    { |seed| seed.kind }
          i.column("Number")  { |seed| seed.number }
          i.column("Country")  { |seed| seed.country }
          i.column("Has whatsapp")  { |seed| seed.has_whatsapp }
          i.column("Has telegram")  { |seed| seed.has_telegram }
          i.column("Note")  { |seed| seed.note } 
          i.column("Attachments") do |seed|
            seed.attachments
              .map{|a| link_to a.document_file_name, a.document.url, target: '_blank'}
              .join("<br />").html_safe
          end
          i.column("") { |seed|
            link_to("View", phone_seed_path(seed))
          }
          i.column("") { |seed|
            link_to("Edit", edit_phone_seed_path(seed))
          }
        end
      end
    end

    if issue.observations.any?
      panel 'Observations' do
        table_for issue.observations do |o|
          o.column("ID") do |obv|
            link_to(obv.id, observation_path(obv))
          end
          o.column("Created at") { |obv| obv.created_at }
          o.column("Updated at") { |obv| obv.updated_at } 
          o.column("Note")    { |obv| obv.note }
          o.column("Reply")   { |obv| obv.reply }
          o.column("Reason")  { |obv| obv.observation_reason.subject }
          o.column("Scope")   { |obv| obv.scope }  
        end
      end
    end
  end
end
