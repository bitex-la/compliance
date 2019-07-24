ActiveAdmin.register Person do
  includes :emails, :legal_entity_dockets, :natural_dockets

  controller do
    include Zipline

    def find_resource
      scoped_collection
        .includes(*Person.eager_person_entities, {issues: Issue.eager_issue_entities.flatten })
        .where(id: params[:id])
        .first!
    end
  end

  actions :all, except: [:destroy]
  action_item :enable, only: [:edit, :show, :update], if: -> {!current_admin_user.is_restricted && !resource.enabled} do 
    link_to "Enable", [:enable, :person], method: :post
  end
  action_item :disable, only: [:edit, :show, :update], if: -> {!current_admin_user.is_restricted && resource.enabled} do 
    link_to "Disable", [:disable, :person], method: :post
  end

  collection_action :search_person, method: :get do 
    keyword = params[:q][:groupings]['0'][:keyword_contains]
    render json: Person.suggest(keyword)
  end

  member_action :enable, method: :post do
    resource.update!(enabled: true)
    redirect_to action: :show
  end

  member_action :disable, method: :post do
    resource.update!(enabled: false)
    redirect_to action: :show
  end
  
  collection_action :search_country, method: :get do 
    keyword = params[:term]
    render json: I18n.t('countries').invert
      .select{|x| x.downcase.starts_with?(keyword)}
      .map{|k, v| {
        label: k,
        value: v
      }}
  end

  filter :emails_address_cont, label: "Email"
  filter :identifications_number_or_argentina_invoicing_details_tax_id_or_chile_invoicing_details_tax_id_cont, label: "ID Number"
  filter :natural_dockets_first_name_cont, label: "First Name"
  filter :natural_dockets_last_name_cont,  label: "Last Name"
  filter :legal_entity_dockets_legal_name_or_legal_entity_dockets_commercial_name_cont, label: "Company Name"
  filter :by_person_type, as: :select, collection: Person.person_types
  filter :notes_title_or_notes_body_cont, label: "Notes"
  filter :domiciles_street_address_or_argentina_invoicing_details_address_cont, label: "Street Address"
  filter :domiciles_street_number_or_argentina_invoicing_details_address_cont, label: "Street Number"
  filter :domiciles_postal_code_or_argentina_invoicing_details_address_cont, label: "Postal Code"
  filter :natural_dockets_politically_exposed_eq, as: :select, label: "Is PEP"
  filter :created_at
  filter :updated_at
  filter :enabled
  filter :risk
  filter :regularity
  filter :tags_id , as: :select, collection: proc { Tag.people }, multiple: true

  scope :all
  scope('Legal Entity') { |scope| scope.merge(Person.by_person_type("legal")) }
  scope('Natural Person') { |scope| scope.merge(Person.by_person_type("natural")) }

  action_item :add_person_information, only: %i(show edit) do
    link_to 'Add Person Information', new_with_fruits_person_issues_path(person)
  end

  action_item :view_person_issues, only: %i(show edit) do
    link_to 'View Person Issues', person_issues_path(person)
  end

  action_item :download_attachments, only: :show do
    if resource.all_attachments.any?
      link_to :download_files.to_s.titleize, [:download_files, :person], method: :post
    end
  end

  member_action :download_files, method: :post do
    files = resource.all_attachments.map { |a| [a.document, a.document_file_name] }
    zipline(files, "person_#{resource.id}_kyc_files.zip")
  end

  form do |f|
    f.inputs 'Basics' do
      f.input :risk, as:  :select, collection: %w(low medium high)
    end

    ArbreHelpers::Form.has_many_form self, f, :comments do |cf, context|
      cf.input :title
      cf.input :meta
      cf.input :body
    end

    ArbreHelpers::Form.has_many_form self, f, :person_taggings, 
      new_button_text: "Add New Tag" do |cf, context|
        cf.input :tag, as:  :select, collection: Tag.people
    end

    f.actions
  end

  index do
    column :id
    column :person_info
    column :enabled
    column :risk
    column :regularity
    column :person_type
    column :created_at
    column :updated_at
    actions
  end

  show do
    tabs do
      ArbreHelpers::Layout.tab_for(self, 'Base', 'info') do
        columns do
          column do
            attributes_table_for resource do
              row :id
              row :enabled
              row :risk
              row :regularity
            end
          end
          column do
            attributes_table_for resource do
              row :created_at
              row :updated_at
              row :tags do  
                resource.tags.pluck(:name).join(' - ')
              end
            end
          end
        end

        if observations = resource.all_observations.sort_by(&:created_at).reverse
          panel "Observations" do
            Appsignal.instrument('render_observations') do
              table_for observations do
                column :issue {|o| link_to "##{o.issue.id}", [resource, o.issue] }
                column :observation_reason
                column :scope
                column "" do |o|
                  span o.note
                  br
                  strong "Reply:"
                  span o.reply
                end
                column :created_at
                column :updated_at
              end
            end
          end
        end

        if fruits = resource.notes.presence
          h3 "Notes"
          ArbreHelpers::Layout.panel_grid(self, fruits) do |d|
            para d.body
            ArbreHelpers::Attachment.attachments_list self, d.attachments
            attributes_table_for d, :issue, :created_at
          end
        end
      end

      if fruit = resource.legal_entity_docket
        ArbreHelpers::Fruit.fruit_collection_show_tab(self, "Legal Entity", :legal_entity_docket, 'industry')
      end
      
      if fruit = resource.natural_docket
        ArbreHelpers::Fruit.fruit_collection_show_tab(self, "Natural", :natural_docket, 'user')
      end

      ArbreHelpers::Fruit.fruit_collection_show_tab(self, "Domicile", :domiciles, 'home')
      ArbreHelpers::Fruit.fruit_collection_show_tab(self, "Id", :identifications, 'id-card')
      ArbreHelpers::Fruit.fruit_collection_show_tab(self, "Allowance", :allowances, 'money')
      ArbreHelpers::Fruit.fruit_collection_show_tab(self, "Invoice Argentina", :argentina_invoicing_details, 'file', 'AR')
      ArbreHelpers::Fruit.fruit_collection_show_tab(self, "Invoice Chile", :chile_invoicing_details, 'file', 'CL')      
      
      ArbreHelpers::Layout.tab_with_counter_for(self, 'Affinity', :all_affinities, 'users') do
        ArbreHelpers::Layout.panel_grid(self, resource.all_affinities) do |d|
          attributes_table_for d do
            ArbreHelpers::Affinity.affinity_card(self, d)
          end
          d.attachments.each do |a|
            ArbreHelpers::Attachment.preview(self, a)
          end
        end
      end

      ArbreHelpers::Fruit.fruit_collection_show_tab(self, "Phone", :phones, 'phone')
      ArbreHelpers::Fruit.fruit_collection_show_tab(self, "Email", :emails, 'envelope')
      ArbreHelpers::Fruit.fruit_collection_show_tab(self, "Risk Score", :risk_scores, 'exclamation-triangle')

      ArbreHelpers::Layout.tab_with_counter_for(self, 'Fund Deposit', :fund_deposits, 'university') do
        panel 'Fund Deposits' , class: 'fund_deposits' do
          table_for person.fund_deposits do           
            column :amount
            column :currency
            column :exchange_rate_adjusted_amount
            column :deposit_method
            column :external_id
          end
        end
      end
    end
  end
end
