ActiveAdmin.register Person do
  actions :all, except: [:destroy]

  action_item only: %i(show edit) do
    link_to 'Add Person Information', new_person_issue_path(person)
    link_to 'View Person Issues', person_issues_path(person)
  end

  form do |f|
    f.inputs 'Basics' do
      f.input :enabled
      f.input :risk, as:  :select, collection: %w(low medium high)
    end

    ArbreHelpers.has_many_form self, f, :comments do |cf, context|
      cf.input :title
      cf.input :meta
      cf.input :body
    end

    f.actions
  end

  show do
    attributes_table do
      row :id
      row :created_at
      row :updated_at
      row :enabled
      row :risk
    end
    
    if person.natural_dockets.any?
      panel 'Natural Docket', class:'natural_docket' do
        table_for person.natural_dockets.current do |n|
          n.column("ID") do |docket|
            link_to(docket.id, natural_docket_path(docket))
          end
          n.column("First Name")      { |docket| docket.first_name }
          n.column("Last Name")       { |docket| docket.last_name }
          n.column("Birthdate")       { |docket| docket.birth_date }
          n.column("Nationality")     { |docket| docket.nationality }
          n.column("Gender")          { |docket| GenderKind.find(docket.gender) }
          n.column("Marital Status")  { |docket| MaritalStatusKind.find(docket.marital_status) }
          n.column("Job Title") { |seed| seed.job_title }
          n.column("Job Description") { |seed| seed.job_description }
          n.column("Politically Exposed") { |seed| seed.politically_exposed }
          n.column("Politically Exposed Reason") { |seed| seed.politically_exposed_reason }
          n.column("Attachments") do |docket|
            docket.attachments
              .map{|a| link_to a.document_file_name, a.document.url, target: '_blank'}
              .join("<br />").html_safe
          end
          n.column("") { |docket|
            link_to("View", natural_docket_path(docket))
          }
        end
      end
    end
  
    if person.legal_entity_dockets.any?
      panel 'Legal Entity Docket', class: 'legal_entity_docket' do
        table_for person.legal_entity_dockets.current do |l|
          l.column("ID") do |docket|
            link_to(docket.id, legal_entity_docket_path(docket))
          end
          l.column("Industry")             { |docket| docket.industry }
          l.column("Business Description") { |docket| docket.business_description }
          l.column("Country")              { |docket| docket.country }
          l.column("Commercial Name")      { |docket| docket.commercial_name }
          l.column("Legal Name")           { |docket| docket.legal_name }
          l.column("Attachments") do |docket|
            docket.attachments
              .map{|a| link_to a.document_file_name, a.document.url, target: '_blank'}
              .join("<br />").html_safe
          end
          l.column("") { |docket|
            link_to("View", legal_entity_docket_path(docket))
          }
        end
      end
    end

    if person.argentina_invoicing_details.any?
      panel 'argentina invoicing details' do
        table_for person.argentina_invoicing_details do |n|
          n.column("ID") do |detail|
            link_to(detail.id, argentina_invoicing_detail_path(detail))
          end
          n.column("VAT status id")      { |detail| detail.vat_status_id }
          n.column("Tax ID")       { |detail| detail.tax_id }
          n.column("Tax ID Type")       { |detail| detail.tax_id_type }
          n.column("Receipt Type")       { |detail| detail.receipt_type }
          n.column("Name")         { |detail| detail.name }
          n.column("Country")       { |detail| detail.country }
          n.column("Address")       { |detail| detail.address }
          n.column("Attachments") do |detail|
            detail.attachments
              .map{|a| link_to a.document_file_name, a.document.url, target: '_blank'}
              .join("<br />").html_safe
          end
          n.column("") { |seed|
            link_to("View", argentina_invoicing_detail_path(seed))
          }
        end
      end
    end

    if person.chile_invoicing_details.any?
      panel 'chile invoicing details' do
        table_for person.chile_invoicing_details do |n|
          n.column("ID") do |d|
            link_to(d.id, chile_invoicing_detail_path(d))
          end
          n.column("VAT status id") { |d| d.vat_status_id }
          n.column("Tax ID")        { |d| d.tax_id }
          n.column("Giro")          { |d| d.giro }
          n.column("Ciudad")        { |d| d.ciudad }
          n.column("Comuna")        { |d| d.comuna }
          n.column("Attachments") do |d|
            d.attachments
              .map{|a| link_to a.document_file_name, a.document.url, target: '_blank'}
              .join("<br />").html_safe
          end
          n.column("") { |d|
            link_to("View", chile_invoicing_detail_path(d))
          }
          n.column("") { |d|
            link_to("Edit", chile_invoicing_detail_path(d))
          }
        end
      end
    end

    if person.identifications.any?
      panel 'Identification' , class: 'identifications'do
        table_for person.identifications.current do |i|
          i.column("ID") do |identification|
            link_to(identification.id, identification_path(identification))
          end
          i.column("Kind")    { |identification| IdentificationKind.find(identification.kind) }
          i.column("Number")  { |identification| identification.number }
          i.column("Issuer")  { |identification| identification.issuer }
          i.column("Public Registry Authority")  { |identification| identification.public_registry_authority }
          i.column("Public Registry Book")  { |identification| identification.public_registry_book }
          i.column("Public Registry Extra Data")  { |identification| identification.public_registry_extra_data }
          i.column("Attachments") do |identification|
            identification.attachments
              .map{|a| link_to a.document_file_name, a.document.url, target: '_blank'}
              .join("<br />").html_safe
          end
          i.column("") { |identification|
            link_to("View", identification_path(identification))
          }
        end
      end
    end
  
    if person.domiciles.any?
      panel 'Domiciles', class: 'domiciles' do
        table_for person.domiciles.current do |d|
          d.column("ID") do |domicile|
            link_to(domicile.id, domicile_path(domicile))
          end
          d.column("Country")         { |domicile| domicile.country }
          d.column("State")           { |domicile| domicile.state }
          d.column("City")            { |domicile| domicile.city }
          d.column("Street Address")  { |domicile| domicile.street_address }
          d.column("Street Number")   { |domicile| domicile.street_number }
          d.column("Postal Code")     { |domicile| domicile.postal_code }
          d.column("Floor")           { |domicile| domicile.floor}
          d.column("Apartment")       { |domicile| domicile.apartment }
          d.column("Attachments") do |domicile|
            domicile.attachments
              .map{|a| link_to a.document_file_name, a.document.url, target: '_blank'}
              .join("<br />").html_safe
          end
          d.column("") { |domicile|
            link_to("View", domicile_path(domicile))
          }
        end
      end
    end
  
    if person.allowances.any?
      panel 'Allowances' , class: 'allowances' do
        table_for person.allowances.current do |q|
          q.column("ID") do |allowance|
            link_to(allowance.id, allowance_path(allowance))
          end
          q.column("Weight") { |allowance| allowance.weight }
          q.column("Amount") { |allowance| allowance.amount }
          q.column("Kind")   { |allowance| allowance.kind }
          q.column("Attachments") do |allowance|
            allowance.attachments
              .map{|a| link_to a.document_file_name, a.document.url, target: '_blank'}
              .join("<br />").html_safe
          end
          q.column("") { |allowance|
            link_to("View", allowance_path(allowance))
          }
        end
      end
    end

    if person.emails.any?
      panel 'Emails' do
        table_for person.emails.current do |i|
          i.column("ID") do |email|
            link_to(email.id, email_path(email))
          end
          i.column("Kind")    { |email| EmailKind.find(email.kind) }
          i.column("Address")  { |email| email.address }
          i.column("Attachments") do |email|
            email.attachments
              .map{|a| link_to a.document_file_name, a.document.url, target: '_blank'}
              .join("<br />").html_safe
          end
          i.column("") { |email|
            link_to("View", email_path(email))
          }
        end
      end
    end

    if person.phones.any?
      panel 'Phones' , class: 'phones' do
        table_for person.phones.current do |q|
          q.column("ID") do |phone|
            link_to(phone.id, phone_path(phone))
          end
          q.column("Number") { |p| p.number }
          q.column("Kind") { |p| PhoneKind.find(p.kind) }
          q.column("Country")   { |p| p.country }
          q.column("Has whatsapp") { |p| p.has_whatsapp }
          q.column("Has telegram") { |p| p.has_telegram }
          q.column("Note") { |p| p.note }
          q.column("Attachments") do |p|
            p.attachments
              .map{|a| link_to a.document_file_name, a.document.url, target: '_blank'}
              .join("<br />").html_safe
          end
          q.column("") { |phone|
            link_to("View", phone_path(phone))
          }
        end
      end
    end
 
    if person.notes.any?
      panel 'Notes' do
        table_for person.notes.current do |i|
          i.column("ID") do |note|
            link_to(note.id, note_path(note))
          end
          i.column("Title") { |note| note.title }
          i.column("Body")  { |note| note.body }
          i.column("Attachments") do |note|
            note.attachments
              .map{|a| link_to a.document_file_name, a.document.url, target: '_blank'}
              .join("<br />").html_safe
          end
          i.column("") { |note|
            link_to("View", note_path(note))
          }
        end
      end
    end

    if person.affinities.any?
      panel 'Affinities' do
        table_for person.affinities do |i|
          i.column("ID") do |fruit|
            link_to(fruit.id, affinity_path(fruit))
          end
          i.column("Kind") do |fruit| 
             rk = RelationshipKind.find(fruit.kind)
             if rk.nil?
	       fruit.kind 	
             else
               rk.code
             end 
          end
          i.column("Related Person")  { |fruit| fruit.related_person }
          i.column("Attachments") do |fruit|
            fruit.attachments
              .map{|a| link_to a.document_file_name, a.document.url, target: '_blank'}
              .join("<br />").html_safe
          end
          i.column("") { |fruit|
            link_to("View", affinity_path(fruit))
          }
        end
      end
    end

    if person.comments.any?
      panel 'Comments' , class: 'comments' do
        table_for person.comments do |q|
          q.column("ID") do |comment|
            link_to(comment.id, comment_path(comment))
          end
          q.column(:title)
          q.column(:meta)
          q.column(:body)
          q.column("") { |comment|
            link_to("View", comment_path(comment))
          }
          q.column("") { |comment|
            link_to("Edit", edit_comment_path(comment))
          }
        end
      end
    end  
  end
end
