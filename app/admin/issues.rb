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

    ArbreHelpers.has_one_form self, f, "Natural Docket", :natural_docket_seed do |sf|
      sf.input :first_name
      sf.input :last_name
      sf.input :birth_date, start_year: 1900
      sf.input :nationality, as: :country
      sf.input :gender, collection: GenderKind.all
      sf.input :marital_status, collection: MaritalStatusKind.all
      sf.input :job_title
      sf.input :job_description
      sf.input :politically_exposed
      sf.input :politically_exposed_reason, input_html: {rows: 3}
      sf.input :copy_attachments
      ArbreHelpers.has_many_attachments(self, sf) 
   end

    ArbreHelpers.has_one_form self, f, "Legal Entity Docket", :legal_entity_docket_seed do |sf|
      sf.input :industry
      sf.input :business_description, input_html: {rows: 3}
      sf.input :country
      sf.input :commercial_name
      sf.input :legal_name
      sf.input :copy_attachments
      ArbreHelpers.has_many_attachments(self, sf)
    end

    ArbreHelpers.has_one_form self, f, "Argentina Invoicing Detail", :argentina_invoicing_detail_seed do |af|
      af.input :vat_status_id
      af.input :tax_id 
      af.input :copy_attachments
      ArbreHelpers.has_many_attachments(self, af)      
    end

    ArbreHelpers.has_one_form self, f, "Chile Invoicing Detail", :chile_invoicing_detail_seed do |cf|
      cf.input :tax_id
      cf.input :giro
      cf.input :ciudad
      cf.input :comuna
      cf.input :copy_attachments
      ArbreHelpers.has_many_attachments(self, cf)
    end

    ArbreHelpers.has_many_form self, f, :identification_seeds do |sf, context|
      sf.input :number
      sf.input :kind, collection: IdentificationKind.all
      sf.input :issuer, as: :country
      sf.input :replaces
      sf.input :public_registry_authority
      sf.input :public_registry_book
      sf.input :public_registry_extra_data
      sf.input :copy_attachments
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
      sf.input :copy_attachments
      ArbreHelpers.has_many_attachments(context, sf)
    end

    ArbreHelpers.has_many_form self, f, :relationship_seeds do |rf, context|
      rf.input :kind, collection: RelationshipKind.all
      rf.input :related_person
      rf.input :replaces
      rf.input :copy_attachments
      ArbreHelpers.has_many_attachments(context, rf)
    end

    ArbreHelpers.has_many_form self, f, :allowance_seeds do |sf, context|
      sf.input :weight 
      sf.input :amount
      sf.input :kind
      sf.input :replaces
      sf.input :copy_attachments
      ArbreHelpers.has_many_attachments(context, sf)
    end

    ArbreHelpers.has_many_form self, f, :phone_seeds do |pf, context|
      pf.input :number
      pf.input :kind, collection: PhoneKind.all
      pf.input :country
      pf.input :replaces
      pf.input :has_whatsapp
      pf.input :has_telegram
      pf.input :note, input_html: {rows: 3} 
      pf.input :copy_attachments
      ArbreHelpers.has_many_attachments(context, pf)
    end  

    ArbreHelpers.has_many_form self, f, :email_seeds do |ef, context|
      ef.input :address
      ef.input :replaces 
      ef.input :kind, collection: EmailKind.all
      ef.input :copy_attachments
      ArbreHelpers.has_many_attachments(context, ef)
    end 

    ArbreHelpers.has_many_form self, f, :note_seeds do |nf, context|
      nf.input :title
      nf.input :replaces 
      nf.input :body, input_html: {rows: 3}
      nf.input :copy_attachments
      ArbreHelpers.has_many_attachments(context, nf)
    end  

    ArbreHelpers.has_many_form self, f, :observations do |sf|
      sf.input :observation_reason
      sf.input :scope
      sf.input :note, input_html: {rows: 3}
      sf.input :reply, input_html: {rows: 3}
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
          n.column("Gender")          { |seed| GenderKind.find(seed.gender) }
          n.column("Marital Status")  { |seed| MaritalStatusKind.find(seed.marital_status) }
          n.column("Job Title") { |seed| seed.job_title }
          n.column("Job Description") { |seed| seed.job_description }
          n.column("Politically Exposed") { |seed| seed.politically_exposed }
          n.column("Politically Exposed Reason") { |seed| seed.politically_exposed_reason }
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

    if issue.chile_invoicing_detail_seed.present?
      panel 'chile invoicing details seed' do
        table_for issue.chile_invoicing_detail_seed do |n|
          n.column("ID") do |seed|
            link_to(seed.id, chile_invoicing_detail_seed_path(seed))
          end
          n.column("Tax ID")       { |seed| seed.tax_id }
          n.column("Giro")       { |seed| seed.giro }
          n.column("Ciudad")       { |seed| seed.ciudad }
          n.column("Comuna")       { |seed| seed.comuna }
          n.column("Attachments") do |seed|
            seed.attachments
              .map{|a| link_to a.document_file_name, a.document.url, target: '_blank'}
              .join("<br />").html_safe
          end
          n.column("") { |seed|
            link_to("View", chile_invoicing_detail_seed_path(seed))
          }
          n.column("") { |seed|
            link_to("Edit", chile_invoicing_detail_seed_path(seed))
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
          q.column("Replaces")  { |seed| seed.replaces }
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
          d.column("Replaces")  { |seed| seed.replaces }
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
          i.column("Kind")    { |seed| IdentificationKind.find(seed.kind) }
          i.column("Number")  { |seed| seed.number }
          i.column("Issuer")  { |seed| seed.issuer }
          i.column("Public Registry Authority")  { |seed| seed.public_registry_authority }
          i.column("Public Registry Book")  { |seed| seed.public_registry_book }
          i.column("Public Registry Extra Data")  { |seed| seed.public_registry_extra_data }
          i.column("Replaces")  { |seed| seed.replaces }
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
          i.column("Kind")    { |seed| EmailKind.find(seed.kind) }
          i.column("Address")  { |seed| seed.address }
          i.column("Replaces")  { |seed| seed.replaces }
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
          i.column("Kind")    { |seed| PhoneKind.find(seed.kind) }
          i.column("Number")  { |seed| seed.number }
          i.column("Country")  { |seed| seed.country }
          i.column("Has whatsapp")  { |seed| seed.has_whatsapp }
          i.column("Has telegram")  { |seed| seed.has_telegram }
          i.column("Note")  { |seed| seed.note } 
          i.column("Replaces")  { |seed| seed.replaces }
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

    if issue.note_seeds.any?
      panel 'Note seeds' do
        table_for issue.note_seeds do |i|
          i.column("ID") do |seed|
            link_to(seed.id, note_seed_path(seed))
          end
          i.column("Title") { |seed| seed.title }
          i.column("Body")  { |seed| seed.body }
          i.column("Replaces")  { |seed| seed.replaces }
          i.column("Attachments") do |seed|
            seed.attachments
              .map{|a| link_to a.document_file_name, a.document.url, target: '_blank'}
              .join("<br />").html_safe
          end
          i.column("") { |seed|
            link_to("View", note_seed_path(seed))
          }
          i.column("") { |seed|
            link_to("Edit", edit_note_seed_path(seed))
          }
        end
      end
    end

    if issue.relationship_seeds.any?
      panel 'Relationship seeds' do
        table_for issue.relationship_seeds do |i|
          i.column("ID") do |seed|
            link_to(seed.id, relationship_seed_path(seed))
          end
          i.column("Kind")    { |seed| RelationshipKind.find(seed.kind).code }
          i.column("Related Person")  { |seed| seed.related_person }
          i.column("Attachments") do |seed|
            seed.attachments
              .map{|a| link_to a.document_file_name, a.document.url, target: '_blank'}
              .join("<br />").html_safe
          end
          i.column("") { |seed|
            link_to("View", relationship_seed_path(seed))
          }
          i.column("") { |seed|
            link_to("Edit", edit_relationship_seed_path(seed))
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
