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

        h3 "Notes"
        ArbreHelpers::Seed.show_full_seed(self, NoteSeed, :notes) do
          div class: 'note_seeds' do
            ArbreHelpers::Form.has_many_form self, f, :note_seeds do |nf, context|
              nf.input :body, input_html: {rows: 3}
              nf.input :expires_at, as: :datepicker
              ArbreHelpers::Attachment.has_many_attachments(context, nf)
            end
          end
        end
      end

      ArbreHelpers::Layout.tab_with_counter_for(self, 'Observations', resource.observations.count, 'bell') do
        columns do
          column span: 2 do
            h3 "Observations"
            ArbreHelpers::Observation.has_many_observations(self, f, :observations)
          end
          column do
            h3 "Observations history"
            ArbreHelpers::Observation.show_observations_history(self, Observation.history(resource) )
          end
        end
      end

      if resource.for_person_type == :legal_entity || resource.for_person_type.nil?
        ArbreHelpers::Seed.seed_collection_and_fruits_edit_tab(self, 'industry', LegalEntityDocketSeed, :legal_entity_docket) do
          ArbreHelpers::Form.has_one_form self, f, "Legal Entity Docket", :legal_entity_docket_seed do |sf|
            sf.input :commercial_name
            sf.input :legal_name
            sf.input :industry
            sf.input :business_description, input_html: {rows: 3}
            sf.input :country, as: :autocomplete, url: search_country_people_path
            
            if resource.person.legal_entity_docket
              sf.input :copy_attachments,
                label: "Move existing Legal Entity Docket attachments to the new one"
            end
            sf.input :expires_at, as: :datepicker
            ArbreHelpers::Observation.has_many_observations(self, sf, :observations, true)
            ArbreHelpers::Attachment.has_many_attachments(self, sf)
          end
        end  
      end
      
      if resource.for_person_type == :natural_person || resource.for_person_type.nil?
        ArbreHelpers::Seed.seed_collection_and_fruits_edit_tab(self, 'user', NaturalDocketSeed, :natural_docket) do
          ArbreHelpers::Form.has_one_form self, f, "Natural Docket", :natural_docket_seed do |sf|
            sf.input :first_name
            sf.input :last_name
            sf.input :birth_date, as: :datepicker,
              datepicker_options: {
                change_year: true,
                change_month: true
              }
            sf.input :nationality, as: :autocomplete, url: search_country_people_path
            sf.input :gender_id, as: :select, collection: GenderKind.all
            sf.input :marital_status_id, as: :select, collection: MaritalStatusKind.all
            sf.input :job_title
            sf.input :job_description
            sf.input :politically_exposed
            sf.input :politically_exposed_reason, input_html: {rows: 3}
            if resource.person.natural_docket
              sf.input :copy_attachments,
                label: "Move existing Natural Person Docket attachments to the new one"
            end
            sf.input :expires_at, as: :datepicker
            ArbreHelpers::Observation.has_many_observations(self, sf, :observations,true)
            ArbreHelpers::Attachment.has_many_attachments(self, sf)
          end
        end
      end

      ArbreHelpers::Seed.seed_collection_and_fruits_edit_tab(self, 'home', DomicileSeed, :domiciles) do
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
          ArbreHelpers::Observation.has_many_observations(self, sf, :observations,true)
          ArbreHelpers::Attachment.has_many_attachments(context, sf)
        end
      end

      ArbreHelpers::Seed.seed_collection_and_fruits_edit_tab(self, 'id-card', IdentificationSeed, :identifications) do
        ArbreHelpers::Form.has_many_form self, f, :identification_seeds do |sf, context|
          sf.input :number
          sf.input :identification_kind_id, as: :select, collection: IdentificationKind.all
          sf.input :issuer, as: :autocomplete, url: '/people/search_country'
          sf.input :public_registry_authority
          sf.input :public_registry_book
          sf.input :public_registry_extra_data
          ArbreHelpers::Replacement.fields_for_replaces context, sf, :identifications
          sf.input :expires_at, as: :datepicker
          ArbreHelpers::Observation.has_many_observations(self, sf, :observations,true)
          ArbreHelpers::Attachment.has_many_attachments(context, sf)
        end
      end

      ArbreHelpers::Seed.seed_collection_and_fruits_edit_tab(self, 'money', AllowanceSeed, :allowances) do
        ArbreHelpers::Form.has_many_form self, f, :allowance_seeds do |sf, context|
          sf.input :amount
          sf.input :kind_id, as: :select, collection: Currency.all.select{|x| ![1, 2, 3].include? x.id}
          ArbreHelpers::Replacement.fields_for_replaces context, sf, :allowances
          sf.input :expires_at, as: :datepicker
          ArbreHelpers::Observation.has_many_observations(self, sf, :observations,true)
          ArbreHelpers::Attachment.has_many_attachments(context, sf)
        end
      end
     
      ArbreHelpers::Seed.seed_collection_and_fruits_edit_tab(self, 'file', ArgentinaInvoicingDetailSeed, :argentina_invoicing_details, 'AR') do
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
          ArbreHelpers::Observation.has_many_observations(self, af, :observations,true)
          ArbreHelpers::Attachment.has_many_attachments(self, af)
        end
      end
    
      ArbreHelpers::Seed.seed_collection_and_fruits_edit_tab(self, 'file', ChileInvoicingDetailSeed, :chile_invoicing_details, 'CL') do
        ArbreHelpers::Form.has_one_form self, f, "Chile Invoicing Detail", :chile_invoicing_detail_seed do |cf|
          cf.input :vat_status_id, as: :select, collection: VatStatusKind.all
          cf.input :tax_id
          cf.input :giro
          cf.input :ciudad
          cf.input :comuna
          ArbreHelpers::Replacement.fields_for_replaces self, cf, :chile_invoicing_details
          cf.input :expires_at, as: :datepicker
          ArbreHelpers::Observation.has_many_observations(self, cf, :observations,true)
          ArbreHelpers::Attachment.has_many_attachments(self, cf)
        end
      end

      ArbreHelpers::Seed.seed_collection_and_fruits_edit_tab(self, 'users', AffinitySeed, :all_affinities) do
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
          ArbreHelpers::Observation.has_many_observations(self, rf, :observations,true)
          ArbreHelpers::Attachment.has_many_attachments(context, rf)
        end
      end

      ArbreHelpers::Seed.seed_collection_and_fruits_edit_tab(self, 'phone', PhoneSeed, :phones) do
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
          ArbreHelpers::Observation.has_many_observations(self, pf, :observations,true)
        end
      end

      ArbreHelpers::Seed.seed_collection_and_fruits_edit_tab(self, 'envelope', EmailSeed, :emails) do
        ArbreHelpers::Form.has_many_form self, f, :email_seeds do |ef, context|
          ef.input :address
          ef.input :email_kind_id, as: :select, collection: EmailKind.all
          if current = context.resource.person.emails.current.presence
            ef.input :replaces, collection: current
          end
          ef.input :expires_at, as: :datepicker
          ArbreHelpers::Observation.has_many_observations(self, ef, :observations,true)
        end
      end

      ArbreHelpers::Seed.seed_collection_and_fruits_edit_tab(self, 'exclamation-triangle', RiskScoreSeed, :risk_scores) do
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
          ArbreHelpers::Observation.has_many_observations(self, rs, :observations,true)
          ArbreHelpers::Attachment.has_many_attachments(context, rs)
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

        h3 "Notes"
        ArbreHelpers::Seed.show_full_seed(self, NoteSeed, :notes) do
          h3 "Current Note Seeds"
          if seeds = resource.note_seeds.presence
            ArbreHelpers::Layout.panel_grid(self, seeds) do |d|
              attributes_table_for d, :fruit
              para d.body
              ArbreHelpers::Attachment.attachments_list self, (d.fruit.try(:attachments) || d.attachments)
            end
          else
            ArbreHelpers::Layout.alert(self, "No items available", "info")
          end
        end
      end
      
      ArbreHelpers::Layout.tab_with_counter_for(self, 'Observations', resource.observations.count, 'bell') do
        columns do
          column span: 2 do
            h3 "Issue Observations"
            ArbreHelpers::Observation.show_observations(self, resource.observations.select { |o| o.observable.nil?} )
            h3 "Seeds Observations"
            ArbreHelpers::Observation.show_observations(self, resource.observations.select { |o| !o.observable.nil?} )
          end
          column do
            h3 "Observations history"
            ArbreHelpers::Observation.show_observations_history(self, Observation.history(resource) )
          end
        end
      end

      if resource.for_person_type == :legal_entity || resource.for_person_type.nil?
        ArbreHelpers::Seed.seed_collection_and_fruits_show_tab(self, 'industry', LegalEntityDocketSeed, :legal_entity_docket)
      end
      
      if resource.for_person_type == :natural_person || resource.for_person_type.nil?
        ArbreHelpers::Seed.seed_collection_and_fruits_show_tab(self, 'user', NaturalDocketSeed, :natural_docket)
      end

      ArbreHelpers::Seed.seed_collection_and_fruits_show_tab(self, 'home', DomicileSeed, :domiciles)
      ArbreHelpers::Seed.seed_collection_and_fruits_show_tab(self, 'id-card', IdentificationSeed, :identifications)
      ArbreHelpers::Seed.seed_collection_and_fruits_show_tab(self, 'money', AllowanceSeed, :allowances)
      ArbreHelpers::Seed.seed_collection_and_fruits_show_tab(self, 'file', ArgentinaInvoicingDetailSeed, :argentina_invoicing_details, 'AR')
      ArbreHelpers::Seed.seed_collection_and_fruits_show_tab(self, 'file', ChileInvoicingDetailSeed, :chile_invoicing_details, 'CL')
      ArbreHelpers::Seed.seed_collection_and_fruits_show_tab(self, 'users', AffinitySeed, :all_affinities)
      ArbreHelpers::Seed.seed_collection_and_fruits_show_tab(self, 'phone', PhoneSeed, :phones)
      ArbreHelpers::Seed.seed_collection_and_fruits_show_tab(self, 'envelope', EmailSeed, :emails)
      ArbreHelpers::Seed.seed_collection_and_fruits_show_tab(self, 'exclamation-triangle', RiskScoreSeed, :risk_scores)
    end
  end
end
