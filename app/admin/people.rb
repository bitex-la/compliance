ActiveAdmin.register Person do
  includes :emails, :legal_entity_dockets, :natural_dockets

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

      ArbreHelpers.fruit_collection_show_tab(self, "Affinity", :affinities)

      tab "Contact (#{resource.phones.count + resource.emails.count})" do
        ArbreHelpers.panel_grid(self, resource.phones) do |d|
          ArbreHelpers.fruit_show_section(self, d)
        end

        ArbreHelpers.panel_grid(self, resource.emails) do |d|
          ArbreHelpers.fruit_show_section(self, d)
        end
      end

      ArbreHelpers.fruit_collection_show_tab(self, "Risk Score", :risk_scores)

      if person.fund_deposits.any?
        panel 'Fund Deposits' , class: 'fund_deposits' do
          table_for person.fund_deposits do |q|
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

      if Affinity.where(related_person: person).any?
        panel 'Affinities with me' do
          table_for Affinity.where(related_person: person).includes(:attachments) do |i|
            i.column("Person") do |fruit|
              link_to fruit.person.person_email, fruit.person
            end
            i.column("Kind") do |fruit|
              fruit.affinity_kind
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

    tab :attachments_preview do
      ArbreHelpers.attachments_grid(self, resource.all_current_attachments, true)
    end
  end
end
