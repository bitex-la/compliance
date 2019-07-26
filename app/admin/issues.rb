ActiveAdmin.register Issue do
  belongs_to :person
  actions :all, except: :destroy 

  filter :created_at
  filter :updated_at

  index do
    column(:id)  do |o|
      link_to o.id, [o.person, o]
    end
    column(:person) do |o|
      link_to o.person.person_info, o.person
    end
    column(:person_state)do |o|
      o.person.state
    end
    column(:reason) do |o| 
      tags =  o.tags.any? ?  "(#{o.tags.pluck(:name).join(' - ')})" : "" 
      "#{o.reason} #{tags}"
    end
    column(:state)
    column(:created_at)
    column(:updated_at)
    column(:defer_until)
    actions
  end

  config.clear_action_items!
  action_item :new, only: [:index] do
    link_to 'New', new_person_issue_path(person)
  end

  action_item :edit, only: [:show] do
    next unless resource.editable?
    link_to 'Edit', edit_person_issue_path(person, resource)
  end

  scope :fresh, default: true
  scope :answered
  scope :draft
  scope :observed
  scope :dismissed
  scope :abandoned
  scope :approved
  scope :changed_after_observation
  scope :future

  collection_action :new_with_fruits, method: :get do
    @person = Person.find(params[:person_id])
    render 'new_with_fruits'
  end

  collection_action :create_from_fruits, method: :post do
    person = Person.find(params[:person_id])
    if !params[:fruits].blank?
      fruits = params[:fruits].map do |pair|
        cls, id = pair.split("_")
        Object.const_get(cls).find(id)
      end
    end
    issue = person.issues.create
    issue.add_seeds_replacing(fruits) unless params[:fruits].blank?
    redirect_to edit_person_issue_url(person, issue)
  end

  Issue.aasm.events.map(&:name).reject{|x| [:observe, :answer].include? x}.each do |action|
    action_item action, only: [:show], if: lambda { resource.send("may_#{action}?") } do
      next if Issue.restricted_actions.include?(action) && current_admin_user.is_restricted?
      link_to action.to_s.titleize, [action, :person, :issue], method: :post
    end

    member_action action, method: :post do
      begin
        resource.send("#{action}!")
      rescue ActiveRecord::RecordInvalid => invalid
        flash[:error] = invalid.record.errors.full_messages.join('-') unless invalid.record.errors.full_messages.empty?
      rescue AASM::InvalidTransition => e
        flash[:error] = e.message
      end
      redirect_to person_issue_url(resource.person, resource)
    end
  end

  controller do
    def scoped_collection
      super.includes :person,
        observations: [:observation_reason]
    end

    def show
      resource.unlock_issue!
      super
    end
    
    def edit
      @page_title = resource.name
      return redirect_to person_issue_url(resource.person, resource) unless resource.editable?
      resource.lock_issue!
      super
    end
  end

  form do |f|
    if f.object.locked? && !f.object.locked_by_me?
      remaining = f.object.lock_remaining_minutes
      
      msg = "Issue is locked by #{f.object.lock_admin_user.email}"
      if remaining != -1
        msg += " and expires in #{remaining} minutes."
      else
        msg += " and the lock don't expires."
      end

      div class: 'flash flash_danger' do
        "#{msg} You cannot make changes until the lock is free."
      end
      br
    end
  
    unless f.object.errors.full_messages.empty?
      ul class: 'validation_errors' do
        f.object.errors.full_messages.each do |e|
          li e
        end
      end
      br

      resource.all_attachments.each do |a|
        next if a.persisted?
        div class: 'flash flash_danger' do
          "A new attachment for a #{a.attached_to_seed_type} was not saved, please select the file again."
        end
        br
      end
    end

    f.input :person_id, as: :hidden

    tabs do
      ArbreHelpers::Layout.tab_for(self, 'Base', 'info') do
        columns do
          column do
            attributes_table_for resource do
              row :id
              row :state
              row :person
              row :reason if f.object.persisted?
            end
          end
          column do
            attributes_table_for resource do
              row :created_at
              row :updated_at
            end
          end
        end

        f.inputs "Issue" do
          f.input :reason, as: :select, collection: IssueReason.all unless f.object.persisted?
          f.input :defer_until, as: :datepicker, datepicker_options: {
              min_date: Date.today }

          ArbreHelpers::Form.has_many_form self, f, :issue_taggings, 
            new_button_text: "Add New Tag" do |cf, context|
              cf.input :tag, as:  :select, collection: Tag.issues
          end
        end

        h3 "Observations"
        ArbreHelpers::Form.has_many_form self, f, :observations, cant_remove: true do |sf|
          sf.input :observation_reason
          sf.input :scope, as: :select
          sf.input :note, input_html: {rows: 3}
          sf.input :reply, input_html: {rows: 3}
        end

        h3 "Notes Seeds"
        columns do
          column span: 2 do
            div class: 'note_seeds' do
              ArbreHelpers::Form.has_many_form self, f, :note_seeds do |nf, context|
                nf.input :body, input_html: {rows: 3}
                nf.input :expires_at, as: :datepicker
                ArbreHelpers::Attachment.has_many_attachments(context, nf)
              end
            end
          end
          column do
            ArbreHelpers::Fruit.current_fruits_panel(self, resource.person.notes)
            ArbreHelpers::Seed.others_seeds_panel(self, NoteSeed)
          end
        end
      end

      if resource.for_person_type == :legal_entity || resource.for_person_type.nil?
        ArbreHelpers::Layout.tab_with_counter_for(self, 'Legal Entity', resource.legal_entity_docket_seed ? 1 : 0 , 'industry') do
          columns do
            column span: 2 do
              ArbreHelpers::Form.has_one_form self, f, "Legal Entity Docket", :legal_entity_docket_seed do |sf|
                sf.input :commercial_name
                sf.input :legal_name
                sf.input :industry
                sf.input :business_description, input_html: {rows: 3}
                Appsignal.instrument("render_country_for_docket") do
                  sf.input :country, as: :autocomplete, url: search_country_people_path
                end
                if resource.person.legal_entity_docket
                  sf.input :copy_attachments,
                    label: "Move existing Legal Entity Docket attachments to the new one"
                end
                sf.input :expires_at, as: :datepicker
                ArbreHelpers::Attachment.has_many_attachments(self, sf)
              end
            end
            column do
              ArbreHelpers::Fruit.current_fruits_panel(self, resource.person.legal_entity_docket)
              ArbreHelpers::Seed.others_seeds_panel(self, LegalEntityDocketSeed)
            end
          end
        end  
      end
      
      if resource.for_person_type == :natural_person || resource.for_person_type.nil?
        ArbreHelpers::Layout.tab_with_counter_for(self, 'Natural', resource.natural_docket_seed ? 1 : 0, 'user') do
          columns do
            column span: 2 do
              ArbreHelpers::Form.has_one_form self, f, "Natural Docket", :natural_docket_seed do |sf|
                Appsignal.instrument("rendering_first_natural_docket_fields") do
                  sf.input :first_name
                  sf.input :last_name
                  sf.input :birth_date, as: :datepicker,
                    datepicker_options: {
                      change_year: true,
                      change_month: true
                    }
                  sf.input :nationality, as: :autocomplete, url: search_country_people_path
                end
                Appsignal.instrument("rendering_association_natural_docket_fields") do
                  sf.input :gender_id, as: :select, collection: GenderKind.all
                  sf.input :marital_status_id, as: :select, collection: MaritalStatusKind.all
                end
                Appsignal.instrument("rendering_last_natural_docket_fields") do
                  sf.input :job_title
                  sf.input :job_description
                  sf.input :politically_exposed
                  sf.input :politically_exposed_reason, input_html: {rows: 3}
                  if resource.person.natural_docket
                    sf.input :copy_attachments,
                      label: "Move existing Natural Person Docket attachments to the new one"
                  end
                end
                sf.input :expires_at, as: :datepicker
                Appsignal.instrument("rendering_has_many_attachments_on_docket") do
                  ArbreHelpers::Attachment.has_many_attachments(self, sf)
                end
              end
            end
            column do
              ArbreHelpers::Fruit.current_fruits_panel(self, resource.person.natural_docket)
              ArbreHelpers::Seed.others_seeds_panel(self, NaturalDocketSeed)
            end
          end
        end
      end

      ArbreHelpers::Layout.tab_with_counter_for(self, 'Domicile', resource.domicile_seeds.count, 'home') do
        columns do
          column span: 2 do
            ArbreHelpers::Form.has_many_form self, f, :domicile_seeds do |sf, context|
              sf.input :country, as: :autocomplete, url: '/people/search_country'
              sf.input :state
              sf.input :city
              sf.input :street_address
              sf.input :street_number
              sf.input :postal_code
              sf.input :floor
              sf.input :apartment
              ArbreHelpers::Replacement.fields_for_replaces context, sf, :domiciles
              sf.input :expires_at, as: :datepicker
              ArbreHelpers::Attachment.has_many_attachments(context, sf)
            end
          end
          column do
            ArbreHelpers::Fruit.current_fruits_panel(self, resource.person.domiciles)
            ArbreHelpers::Seed.others_seeds_panel(self, DomicileSeed)
          end
        end
      end

      ArbreHelpers::Layout.tab_with_counter_for(self, 'ID', resource.identification_seeds.count, 'id-card') do
        columns do
          column span: 2 do
            ArbreHelpers::Form.has_many_form self, f, :identification_seeds do |sf, context|
              sf.input :number
              sf.input :identification_kind_id, as: :select, collection: IdentificationKind.all
              sf.input :issuer, as: :autocomplete, url: '/people/search_country'
              sf.input :public_registry_authority
              sf.input :public_registry_book
              sf.input :public_registry_extra_data
              ArbreHelpers::Replacement.fields_for_replaces context, sf, :identifications
              sf.input :expires_at, as: :datepicker
              ArbreHelpers::Attachment.has_many_attachments(context, sf)
            end
          end
          column do
            ArbreHelpers::Fruit.current_fruits_panel(self, resource.person.identifications)
            ArbreHelpers::Seed.others_seeds_panel(self, IdentificationSeed)
          end
        end
      end

      ArbreHelpers::Layout.tab_with_counter_for(self, 'Allowance', resource.allowance_seeds.count, 'money') do
        columns do
          column span: 2 do
            ArbreHelpers::Form.has_many_form self, f, :allowance_seeds do |sf, context|
              sf.input :amount
              sf.input :kind_id, as: :select, collection: Currency.all.select{|x| ![1, 2, 3].include? x.id}
              ArbreHelpers::Replacement.fields_for_replaces context, sf, :allowances
              sf.input :expires_at, as: :datepicker
              ArbreHelpers::Attachment.has_many_attachments(context, sf)
            end
          end
          column do
            ArbreHelpers::Fruit.current_fruits_panel(self, resource.person.allowances)
            ArbreHelpers::Seed.others_seeds_panel(self, AllowanceSeed)
          end
        end
      end

      ArbreHelpers::Layout.tab_with_counter_for(self, 'Invoice Argentina', resource.argentina_invoicing_detail_seed ? 1:0, 'file', 'AR') do
        columns do 
          column do
            ArbreHelpers::Form.has_one_form self, f, "Argentina Invoicing Detail", :argentina_invoicing_detail_seed do |af|
              af.input :vat_status_id, as: :select, collection: VatStatusKind.all
              af.input :tax_id
              af.input :tax_id_kind_id, as: :select, collection: TaxIdKind.all
              af.input :receipt_kind_id, as: :select , collection: ReceiptKind.all
              af.input :full_name
              af.input :country, as: :autocomplete, url: search_country_people_path
              af.input :address
              ArbreHelpers::Replacement.fields_for_replaces self, af,
                :argentina_invoicing_details
              af.input :expires_at, as: :datepicker
              ArbreHelpers::Attachment.has_many_attachments(self, af)
            end
          end
          
          column do
            ArbreHelpers::Fruit.current_fruits_panel(self, resource.person.argentina_invoicing_details)
            ArbreHelpers::Seed.others_seeds_panel(self, ArgentinaInvoicingDetailSeed, [:tax_id])
          end
        end
      end

      ArbreHelpers::Layout.tab_with_counter_for(self, 'Invoice Chile', resource.chile_invoicing_detail_seed ? 1:0, 'file', 'CL') do
        columns do 
          column do
            ArbreHelpers::Form.has_one_form self, f, "Chile Invoicing Detail", :chile_invoicing_detail_seed do |cf|
              cf.input :vat_status_id, as: :select, collection: VatStatusKind.all
              cf.input :tax_id
              cf.input :giro
              cf.input :ciudad
              cf.input :comuna
              ArbreHelpers::Replacement.fields_for_replaces self, cf, :chile_invoicing_details
              cf.input :expires_at, as: :datepicker
              ArbreHelpers::Attachment.has_many_attachments(self, cf)
            end
          end
          column do
            ArbreHelpers::Fruit.current_fruits_panel(self, resource.person.chile_invoicing_details)
            ArbreHelpers::Seed.others_seeds_panel(self, ChileInvoicingDetailSeed, [:tax_id])
          end
        end
      end

      ArbreHelpers::Layout.tab_with_counter_for(self, 'Affinity', resource.affinity_seeds.count, 'users') do
        columns do
          column span: 2 do
            ArbreHelpers::Form.has_many_form self, f, :affinity_seeds do |rf, context|
              rf.input :affinity_kind_id, as: :select, collection: AffinityKind.all
              if rf.object.related_person_id.nil?
                rf.input :related_person_id, as: :search_select, url: proc{ search_person_people_path },
                  fields: ['keyword'], display_name: 'suggestion', minimum_input_length: 1
              else
                rf.template.concat('<li>'.html_safe) 
                rf.template.concat("<label>Related person</label>".html_safe)
                rf.template.concat(
                  context.link_to rf.object.related_person.name, rf.object.related_person
                )
                rf.template.concat('</li>'.html_safe) 
              end
              ArbreHelpers::Replacement.fields_for_replaces context, rf, :affinities
              rf.input :expires_at, as: :datepicker
              ArbreHelpers::Attachment.has_many_attachments(context, rf)
            end
          end
          column do 
            Appsignal.instrument('render_current_affinities') do
              h3 "Current affinities"
              ArbreHelpers::Layout.panel_only(self, resource.person.all_affinities) do |d|
                attributes_table_for d do
                  ArbreHelpers::Affinity.affinity_card(self, d)
                end
              end
            end

            ArbreHelpers::Seed.others_seeds_panel(self, AffinitySeed)
          end
        end
      end

      ArbreHelpers::Layout.tab_with_counter_for(self, 'Phone', resource.phone_seeds.count, 'phone') do
        columns do
          column span: 2 do
            ArbreHelpers::Form.has_many_form self, f, :phone_seeds do |pf, context|
              pf.input :number
              pf.input :phone_kind_id, as: :select, collection: PhoneKind.all
              pf.input :country, as: :autocomplete, url: '/people/search_country'
              pf.input :has_whatsapp
              pf.input :has_telegram
              pf.input :note, input_html: {rows: 3}
              if current = context.resource.person.phones.current.presence
                pf.input :replaces, collection: current
              end
              pf.input :expires_at, as: :datepicker
            end
            
          end
          column do
            ArbreHelpers::Fruit.current_fruits_panel(self, resource.person.phones)
            ArbreHelpers::Seed.others_seeds_panel(self, PhoneSeed)
          end
        end
      end

      ArbreHelpers::Layout.tab_with_counter_for(self, 'Email', resource.email_seeds.count, 'envelope') do
        columns do
          column span: 2 do
            ArbreHelpers::Form.has_many_form self, f, :email_seeds do |ef, context|
              ef.input :address
              ef.input :email_kind_id, as: :select, collection: EmailKind.all
              if current = context.resource.person.emails.current.presence
                ef.input :replaces, collection: current
              end
              ef.input :expires_at, as: :datepicker
            end
          end
          column do
            ArbreHelpers::Fruit.current_fruits_panel(self, resource.person.emails)
            ArbreHelpers::Seed.others_seeds_panel(self, EmailSeed)
          end
        end
      end

      ArbreHelpers::Layout.tab_with_counter_for(self, 'Risk Score', resource.risk_score_seeds.count, 'exclamation-triangle') do
        columns do
          column span: 2 do
            ArbreHelpers::Form.has_many_form self, f, :risk_score_seeds do |rs, context|
              rs.input :score
              rs.input :provider
              rs.input :external_link
              if current = context.resource.person.risk_scores.current.presence
                rs.input :replaces, collection: current
              end
              seed = rs.object
              if seed.persisted?     
                ArbreHelpers::HtmlHelper.has_many_links(context, rs, 
                  seed.external_link.split(',').compact,
                  'External links') if seed.external_link 
                begin 
                  if seed.extra_info
                    extra_info_as_json = JSON.parse(seed.extra_info)
                    ArbreHelpers::HtmlHelper.json_renderer(context, extra_info_as_json)
                  end
                rescue JSON::ParserError
                  rs.input :extra_info, input_html: { readonly: true, disabled: true }
                end
              else
                rs.input :extra_info 
              end
              rs.input :expires_at, as: :datepicker
              ArbreHelpers::Attachment.has_many_attachments(context, rs)
            end
          end
          column do
            ArbreHelpers::Fruit.current_fruits_panel(self, resource.person.risk_scores)
            ArbreHelpers::Seed.others_seeds_panel(self, RiskScoreSeed)
          end
        end
      end
    end

    f.actions do
      f.action :submit
      f.cancel_link({action: (resource.persisted? ? :show : :index) })
    end
  end

  show do
    tabs do
      ArbreHelpers::Layout.tab_for(self, 'Base', 'info') do
        columns do
          column do
            attributes_table_for resource do
              row :id
              row :state
              row :person
              row :reason
            end
          end
          column do
            attributes_table_for resource do
              row :created_at
              row :updated_at
              row :defer_until
              row :tags do  
                resource.tags.pluck(:name).join(' - ')
              end
            end
          end
        end

        if observations = resource.observations.presence
          h3 "Observations"
          ArbreHelpers::Layout.panel_grid(self, observations) do |d|
            attributes_table_for d, :observation_reason, :scope, :created_at, :updated_at
            para d.note
            strong "Reply:"
            span d.reply
          end
        end

        h3 "Notes"
        columns do
          column span: 2 do
            h3 "Current Note Seeds"
            if seeds = resource.note_seeds.presence
              ArbreHelpers::Layout.panel_grid(self, seeds) do |d|
                attributes_table_for d, :fruit
                para d.body
                ArbreHelpers::Attachment.attachments_list self, (d.fruit.try(:attachments) || d.attachments)
              end
            else
              div("No items available", class: 'with-bootstrap alert alert-info')
            end
          end
          column do
            ArbreHelpers::Fruit.current_fruits_panel(self, resource.person.notes)
            ArbreHelpers::Seed.others_seeds_panel(self, NoteSeed)
          end
        end
      end
      
      if resource.for_person_type == :legal_entity || resource.for_person_type.nil?
        ArbreHelpers::Seed.seed_collection_and_fruits_show_tab(self, "Legal Entity", :legal_entity_docket_seed, :legal_entity_docket, 'industry')
      end
      
      if resource.for_person_type == :natural_person || resource.for_person_type.nil?
        ArbreHelpers::Seed.seed_collection_and_fruits_show_tab(self, "Natural", :natural_docket_seed, :natural_docket, 'user')
      end

      ArbreHelpers::Seed.seed_collection_and_fruits_show_tab(self, "Domicile", :domicile_seeds, :domiciles, 'home')
      ArbreHelpers::Seed.seed_collection_and_fruits_show_tab(self, "Id", :identification_seeds, :identifications, 'id-card')
      ArbreHelpers::Seed.seed_collection_and_fruits_show_tab(self, "Allowance", :allowance_seeds, :allowances, 'money')
      ArbreHelpers::Seed.seed_collection_and_fruits_show_tab(self, "Invoice Argentina", :argentina_invoicing_detail_seed, :argentina_invoicing_details, 'file', 'AR')
      ArbreHelpers::Seed.seed_collection_and_fruits_show_tab(self, "Invoice Chile", :chile_invoicing_detail_seed, :chile_invoicing_details, 'file', 'CL')
      ArbreHelpers::Seed.seed_collection_and_fruits_show_tab(self, "Affinity", :affinity_seeds, :affinities, 'users')
      ArbreHelpers::Seed.seed_collection_and_fruits_show_tab(self, "Phone", :phone_seeds, :phones, 'phone')
      ArbreHelpers::Seed.seed_collection_and_fruits_show_tab(self, "Email", :email_seeds, :emails, 'envelope')
      ArbreHelpers::Seed.seed_collection_and_fruits_show_tab(self, "Risk Score", :risk_score_seeds, :risk_scores, 'exclamation-triangle')
    end
  end
end
