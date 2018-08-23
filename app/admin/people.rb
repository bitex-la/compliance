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

  filter :created_at
  filter :updated_at
  filter :enabled
  filter :risk

  action_item only: %i(show edit) do
    link_to 'Add Person Information', new_with_fruits_person_issues_path(person)
  end

  action_item only: %i(show edit) do
    link_to 'View Person Issues', person_issues_path(person)
  end

  action_item "Download Attachments", only: :show do
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
    column :person_type
    column :created_at
    column :updated_at
    actions
  end

  show do
    tabs do
      tab :base do
        columns do
          column do
            attributes_table_for resource do
              row :id
              row :enabled
              row :risk
            end
          end
          column do
            attributes_table_for resource do
              row :created_at
              row :updated_at
            end
          end
        end

        if observations = resource.all_observations.sort_by(&:created_at).reverse
          panel "Observations" do
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

        if fruits = resource.notes.presence
          h3 "Notes"
          ArbreHelpers.panel_grid(self, fruits) do |d|
            para d.body
            ArbreHelpers.attachments_list self, d.attachments
            attributes_table_for d, :issue, :created_at
          end
        end
      end

      tab :docket do
        if fruit = resource.legal_entity_docket
          panel fruit.name do
            ArbreHelpers.fruit_show_section(self, fruit)
          end
        end

        if fruit = resource.natural_docket
          panel fruit.name do
            ArbreHelpers.fruit_show_section(self, fruit)
          end
        end
      end

      ArbreHelpers.fruit_collection_show_tab(self, "Domicile", :domiciles)
      ArbreHelpers.fruit_collection_show_tab(self, "Id", :identifications)
      ArbreHelpers.fruit_collection_show_tab(self, "Allowance", :allowances)

      tab "Invoicing" do
        if fruits = resource.argentina_invoicing_details.current.presence
          h3 "Argentina Invoicing details"
          fruits.each do |fruit|
            ArbreHelpers.panel_grid(self, fruits) do |d|
              ArbreHelpers.fruit_show_section(self, d)
            end
          end
        end

        if fruits = resource.chile_invoicing_details.current.presence
          h3 "Chile Invoicing details"
          fruits.each do |fruit|
            ArbreHelpers.panel_grid(self, fruits) do |d|
              ArbreHelpers.fruit_show_section(self, d)
            end
          end
        end
      end

      tab "Affinities" do
        ArbreHelpers.panel_grid(self, resource.all_affinities) do |d|
          attributes_table_for d do
            row(:person)
            row(:related_person)
            row(:affinity_kind)
            row(:created_at)
            row(:issue)
          end
          d.attachments.each do |a|
            ArbreHelpers.attachment_preview(self, a)
          end
        end
      end

      tab "Contact (#{resource.phones.count + resource.emails.count})" do
        ArbreHelpers.panel_grid(self, resource.phones) do |d|
          ArbreHelpers.fruit_show_section(self, d)
        end

        ArbreHelpers.panel_grid(self, resource.emails) do |d|
          ArbreHelpers.fruit_show_section(self, d)
        end
      end

      tab "Fund Deposits" do 
        panel 'Fund Deposits' , class: 'fund_deposits' do
          table_for person.fund_deposits do           
            column :amount
            column :currency
            column :deposit_method
            column :external_id
          end
        end
      end

      ArbreHelpers.fruit_collection_show_tab(self, "Risk Score", :risk_scores)
    end
  end
end
