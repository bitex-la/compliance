ActiveAdmin.register Person do

  controller do
    include Zipline
  end

  actions :all, except: [:destroy]

  filter :created_at
  filter :updated_at
  filter :enabled
  filter :risk

  action_item only: %i(show edit) do
    link_to 'Add Person Information', new_person_issue_path(person)
  end

  action_item only: %i(show edit) do
    link_to 'View Person Issues', person_issues_path(person)
  end

  action_item "Download Attachments", only: :show do
    if resource.attachments.any?
      link_to :download_files.to_s.titleize, [:download_files, :person], method: :post
    end
  end

  member_action :download_files, method: :post do
    files = resource.attachments.map { |a| [a.document, a.document_file_name] }
    zipline(files, "person_#{resource.id}_kyc_files.zip")
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

  index do
    column :id
    column :person_email
    column :enabled
    column :risk
    column :is_a_natural_person?
    column :natural_docket
    column :is_a_legal_entity?
    column :legal_entity_docket
    column :created_at
    column :updated_at
    actions
  end

  show do
    tabs do
      tab :person_info do
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
              n.column("Gender")          { |docket| docket.gender }
              n.column("Marital Status")  { |docket| docket.marital_status }
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

        if person.risk_scores.any?
          panel 'risk scores' do
            table_for person.risk_scores.current do |rs|
              rs.column("ID") do |score|
                link_to(score.id, risk_score_path(score))
              end
              rs.column(:score)
              rs.column(:provider)
              rs.column(:extra_info)
              rs.column(:external_link)
              rs.column("Attachments") do |score|
                score.attachments
                  .map{|a| link_to a.document_file_name, a.document.url, target: '_blank'}
                  .join("<br />").html_safe
              end
              rs.column("") { |score|
                link_to("View", risk_score_path(score))
              }
              rs.column("") { |score|
                link_to("Edit", edit_risk_score_path(score))
              }
            end
          end 
        end

        if person.argentina_invoicing_details.any?
          panel 'argentina invoicing details' do
            table_for person.argentina_invoicing_details.current do |n|
              n.column("ID") do |detail|
                link_to(detail.id, argentina_invoicing_detail_path(detail))
              end
              n.column("VAT status id")      { |detail| detail.vat_status }
              n.column("Tax ID")       { |detail| detail.tax_id }
              n.column("Tax ID Type")       { |detail| detail.tax_id_kind }
              n.column("Receipt Type")       { |detail| detail.receipt_kind }
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
            table_for person.chile_invoicing_details.current do |n|
              n.column("ID") do |d|
                link_to(d.id, chile_invoicing_detail_path(d))
              end
              n.column("VAT status id") { |d| d.vat_status }
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
              i.column("Kind")    { |identification| identification.identification_kind }
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

        if person.fund_deposits.current.any?
          panel 'Fund Deposits' , class: 'fund_deposits' do
            table_for person.fund_deposits.current do |q|
              q.column("ID") do |deposit|
                link_to(deposit.id, fund_deposit_path(deposit))
              end
              q.column("Amount") { |deposit| deposit.amount }
              q.column("Currency") { |deposit| deposit.currency }
              q.column("Deposit Method") { |deposit| deposit.deposit_method }
              q.column("External ID") { |deposit| deposit.external_id }
              q.column("Attachments") do |deposit|
                deposit.attachments
                  .map{|a| link_to a.document_file_name, a.document.url, target: '_blank'}
                  .join("<br />").html_safe
              end
              q.column("") { |deposit|
                link_to("View", fund_deposit_path(deposit))
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
              i.column("Kind")    { |email| email.email_kind }
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
              q.column("Kind") { |p| p.phone_kind }
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
            table_for person.notes.includes(:attachments).current do |i|
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
            table_for person.affinities.includes(:attachments) do |i|
              i.column("ID") do |fruit|
                link_to(fruit.id, affinity_path(fruit))
              end
              i.column("Kind") do |fruit|
                fruit.affinity_kind
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
      tab :attachments do
        ArbreHelpers.multi_entity_attachments self, person, :natural_dockets
        ArbreHelpers.multi_entity_attachments self, person, :legal_entity_dockets
        ArbreHelpers.multi_entity_attachments self, person, :risk_scores
        ArbreHelpers.multi_entity_attachments self, person, :argentina_invoicing_details
        ArbreHelpers.multi_entity_attachments self, person, :chile_invoicing_details
        ArbreHelpers.multi_entity_attachments self, person, :identifications
        ArbreHelpers.multi_entity_attachments self, person, :domiciles
        ArbreHelpers.multi_entity_attachments self, person, :affinities
        ArbreHelpers.multi_entity_attachments self, person, :fund_deposits
        ArbreHelpers.multi_entity_attachments self, person, :allowances
        ArbreHelpers.multi_entity_attachments self, person, :phones
        ArbreHelpers.multi_entity_attachments self, person, :emails
        ArbreHelpers.multi_entity_attachments self, person, :notes
        ArbreHelpers.person_attachments self, person
      end
    end
  end
end
