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
      link_to o.person.person_email, o.person
    end
    column(:person_enabled)do |o|
      o.person.enabled
    end
    column(:state)
    column(:created_at)
    column(:updated_at)
  end

  config.clear_action_items!
  action_item :new, only: [:index] do
    link_to 'New', new_person_issue_path(person)
  end

  scope :fresh, default: true
  scope :answered
  scope :draft
  scope :observed
  scope :dismissed
  scope :abandoned
  scope :approved
  scope :changed_after_observation

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
    redirect_to [person, issue]
  end


  Issue.aasm.events.map(&:name).reject{|x| [:observe, :answer].include? x}.each do |action|
    action_item action, only: [:edit, :update], if: lambda { resource.send("may_#{action}?") } do
      next if Issue.restricted_actions.include?(action) && current_admin_user.is_restricted?
      link_to action.to_s.titleize, [action, :person, :issue], method: :post
    end

    member_action action, method: :post do
      resource.send("#{action}!")
      redirect_to action: :show
    end
  end

  controller do

    def scoped_collection
      super.includes :person,
        observations: [:observation_reason]
    end

    def edit
      @page_title = resource.name
      return redirect_to person_issue_url(resource.person, resource) unless resource.editable?
      super
    end

    def show
      return redirect_to edit_person_issue_url(resource.person, resource) if resource.editable?
      super
    end
  end

  form do |f|

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
      tab :base do
        columns do
          column do
            attributes_table_for resource do
              row :id
              row :state
              row :person
            end
          end
          column do
            attributes_table_for resource do
              row :created_at
              row :updated_at
            end
          end
        end

        h3 "Observations"
        ArbreHelpers.has_many_form self, f, :observations, cant_remove: true do |sf|
          sf.input :observation_reason
          sf.input :scope
          sf.input :note, input_html: {rows: 3}
          sf.input :reply, input_html: {rows: 3}
        end

        h3 "Notes Seeds"
        div class: 'note_seeds' do
          ArbreHelpers.has_many_form self, f, :note_seeds do |nf, context|
            nf.input :body, input_html: {rows: 3}
            nf.input :private
            ArbreHelpers.has_many_attachments(context, nf)
          end
        end
      end

      tab :docket do
        if resource.for_person_type == :legal_entity || resource.for_person_type.nil?
          ArbreHelpers.has_one_form self, f, "Legal Entity Docket", :legal_entity_docket_seed do |sf|
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
            ArbreHelpers.has_many_attachments(self, sf)
          end
        end

        if resource.for_person_type == :natural_person || resource.for_person_type.nil?
          ArbreHelpers.has_one_form self, f, "Natural Docket", :natural_docket_seed do |sf|
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
            Appsignal.instrument("rendering_has_many_attachments_on_docket") do
              ArbreHelpers.has_many_attachments(self, sf)
            end
          end
        end
      end

      tab "Domicile (#{resource.domicile_seeds.count})" do
        ArbreHelpers.has_many_form self, f, :domicile_seeds do |sf, context|
          sf.input :country, as: :autocomplete, url: '/people/search_country'
          sf.input :state
          sf.input :city
          sf.input :street_address
          sf.input :street_number
          sf.input :postal_code
          sf.input :floor
          sf.input :apartment
          ArbreHelpers.fields_for_replaces context, sf, :domiciles
          ArbreHelpers.has_many_attachments(context, sf)
        end
      end

      tab "ID (#{resource.identification_seeds.count})" do
        ArbreHelpers.has_many_form self, f, :identification_seeds do |sf, context|
          sf.input :number
          sf.input :identification_kind_id, as: :select, collection: IdentificationKind.all
          sf.input :issuer, as: :autocomplete, url: '/people/search_country'
          sf.input :public_registry_authority
          sf.input :public_registry_book
          sf.input :public_registry_extra_data
          ArbreHelpers.fields_for_replaces context, sf, :identifications
          ArbreHelpers.has_many_attachments(context, sf)
        end
      end

      tab "Allowance (#{resource.allowance_seeds.count})" do
        ArbreHelpers.has_many_form self, f, :allowance_seeds do |sf, context|
          sf.input :amount
          sf.input :kind_id, as: :select, collection: Currency.all.select{|x| ![1, 2, 3].include? x.id}
          ArbreHelpers.fields_for_replaces context, sf, :allowances
          ArbreHelpers.has_many_attachments(context, sf)
        end
      end

      tab :invoicing do
        columns do 
          column do
            ArbreHelpers.has_one_form self, f, "Argentina Invoicing Detail", :argentina_invoicing_detail_seed do |af|
              af.input :vat_status_id, as: :select, collection: VatStatusKind.all
              af.input :tax_id
              af.input :tax_id_kind_id, as: :select, collection: TaxIdKind.all
              af.input :receipt_kind_id, as: :select , collection: ReceiptKind.all
              af.input :full_name
              af.input :country, as: :autocomplete, url: search_country_people_path
              af.input :address
              ArbreHelpers.fields_for_replaces self, af,
                :argentina_invoicing_details
              ArbreHelpers.has_many_attachments(self, af)
            end
          end
          column do
            ArbreHelpers.has_one_form self, f, "Chile Invoicing Detail", :chile_invoicing_detail_seed do |cf|
              cf.input :vat_status_id, as: :select, collection: VatStatusKind.all
              cf.input :tax_id
              cf.input :giro
              cf.input :ciudad
              cf.input :comuna
              ArbreHelpers.fields_for_replaces self, cf, :chile_invoicing_details
              ArbreHelpers.has_many_attachments(self, cf)
            end
          end
        end
      end

      tab "Affinity (#{resource.affinity_seeds.count})" do
        columns do
          column span: 2 do
            ArbreHelpers.has_many_form self, f, :affinity_seeds do |rf, context|
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
              ArbreHelpers.fields_for_replaces context, rf, :affinities
              ArbreHelpers.has_many_attachments(context, rf)
            end
          end
          column do 
            Appsignal.instrument('render_current_affinities') do
              h3 "Current affinities"
              resource.person.all_affinities.each do |d|
                panel d.name do
                  attributes_table_for d do
                    ArbreHelpers.affinity_card(self, d)
                  end
                end
              end
            end
          end
        end
      end

      tab "Contact (#{resource.phone_seeds.count + resource.email_seeds.count})" do
        ArbreHelpers.has_many_form self, f, :phone_seeds do |pf, context|
          pf.input :number
          pf.input :phone_kind_id, as: :select, collection: PhoneKind.all
          pf.input :country, as: :autocomplete, url: '/people/search_country'
          pf.input :has_whatsapp
          pf.input :has_telegram
          pf.input :note, input_html: {rows: 3}
          if current = context.resource.person.phones.current.presence
            pf.input :replaces, collection: current
          end
        end
        br
        ArbreHelpers.has_many_form self, f, :email_seeds do |ef, context|
          ef.input :address
          ef.input :email_kind_id, as: :select, collection: EmailKind.all
          if current = context.resource.person.emails.current.presence
            ef.input :replaces, collection: current
          end
        end
      end

      tab "Risk Score (#{resource.risk_score_seeds.count})" do
        ArbreHelpers.has_many_form self, f, :risk_score_seeds do |rs, context|
          rs.input :score
          rs.input :provider
          rs.input :external_link
          if current = context.resource.person.risk_scores.current.presence
            rs.input :replaces, collection: current
          end
          seed = rs.object
          if seed.persisted?     
            ArbreHelpers.has_many_links(context, rs, seed.external_link.split(',').compact, 'External links') 
            begin 
              if seed.extra_info
                extra_info_as_json = JSON.parse(seed.extra_info)
                ArbreHelpers.json_renderer(context, extra_info_as_json)
              end
            rescue JSON::ParserError
              rs.input :extra_info, input_html: { readonly: true, disabled: true }
            end
          else
            rs.input :extra_info 
          end

          ArbreHelpers.has_many_attachments(context, rs)
        end
      end
    end

    f.actions
  end

  show do
    next unless resource.approved? # Only show approved issues.

    tabs do
      tab :base do
        columns do
          column do
            attributes_table_for resource do
              row :id
              row :state
              row :person
            end
          end
          column do
            attributes_table_for resource do
              row :created_at
              row :updated_at
            end
          end
        end

        if observations = resource.observations.presence
          h3 "Observations"
          ArbreHelpers.panel_grid(self, observations) do |d|
            attributes_table_for d, :observation_reason, :scope, :created_at, :updated_at
            para d.note
            strong "Reply:"
            span d.reply
          end
        end

        if seeds = resource.note_seeds.presence
          h3 "Note Seeds"
          ArbreHelpers.panel_grid(self, seeds) do |d|
            attributes_table_for d, :fruit
            para d.body
            ArbreHelpers.attachments_list self, d.fruit.try(:attachments)
          end
        end
      end

      tab :docket do
        if seed = issue.legal_entity_docket_seed.presence
          panel seed.name do
            ArbreHelpers.seed_show_section(self, seed)
          end
        end

        if seed = issue.natural_docket_seed.presence
          panel seed.name do
            ArbreHelpers.seed_show_section(self, seed)
          end
        end
      end

      
      ArbreHelpers.seed_collection_show_tab(self, "Domicile", :domicile_seeds)
      ArbreHelpers.seed_collection_show_tab(self, "Id", :identification_seeds)
      ArbreHelpers.seed_collection_show_tab(self, "Allowance", :allowance_seeds)

      tab "Invoicing" do
        if seed = issue.argentina_invoicing_detail_seed.presence
          panel seed.name do
            ArbreHelpers.seed_show_section(self, seed, [:tax_id])
          end
        end

        if seed = issue.chile_invoicing_detail_seed.presence
          panel seed.name do
            ArbreHelpers.seed_show_section(self, seed)
          end
        end
      end

      ArbreHelpers.seed_collection_show_tab(self, "Affinity", :affinity_seeds)

      tab "Contact (#{resource.phone_seeds.count + resource.email_seeds.count})" do
        ArbreHelpers.panel_grid(self, resource.phone_seeds) do |d|
          ArbreHelpers.seed_show_section(self, d)
        end

        ArbreHelpers.panel_grid(self, resource.email_seeds) do |d|
          ArbreHelpers.seed_show_section(self, d)
        end
      end

      ArbreHelpers.seed_collection_show_tab(self, "Risk Score", :risk_score_seeds)
    end
  end
end
