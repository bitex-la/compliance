#encoding: utf-8
ActiveAdmin.register Issue, sort_order: :priority_desc, as: "Dashboard" do
  menu priority: 1

  actions :index

  scope :fresh, default: true
  scope :answered
  scope :draft
  scope :observed
  scope :abandoned
  scope :dismissed
  scope :rejected
  scope :approved
  scope :future
  scope :all

  filter :email_seeds_address_cont, label: "Email"
  filter :identification_seeds_number_or_argentina_invoicing_detail_seed_tax_id_or_chile_invoicing_detail_seed_tax_id_cont, label: "ID Number"
  filter :natural_docket_seed_first_name_cont, label: "First Name"
  filter :natural_docket_seed_last_name_cont,  label: "Last Name"
  filter :natural_docket_seed_nationality_eq,
    label: 'Nationality', as: :autocomplete,
    url: proc { search_country_people_path },
    required: false, wrapper_html: { style: "list-style: none" }
  filter :natural_docket_seed_expected_investment, label: "Expected Investment", as: :numeric
  filter :legal_entity_docket_seed_legal_name_or_legal_entity_docket_seed_commercial_name_cont, label: "Company Name"
  filter :by_person_type, as: :select, collection: Person.person_types
  filter :person_tpi, as: :select, collection: Person.tpis, label: 'By Person TPI'
  filter :note_seeds_title_or_note_seeds_body_cont, label: "Notes"
  filter :domicile_seeds_street_address_or_argentina_invoicing_detail_seed_address_cont, label: "Street Address"
  filter :domicile_seeds_street_number_or_argentina_invoicing_detail_seed_address_cont, label: "Street Number"
  filter :domicile_seeds_postal_code_or_argentina_invoicing_detail_seed_address_cont, label: "Postal Code"
  filter :natural_docket_seed_politically_exposed_eq, as: :select, label: "Is PEP"
  filter :reason
  filter :tags_id , as: :select, collection: proc { Tag.issues }, multiple: true
  filter :by_person_tag , as: :select, collection: proc { Tag.people }, multiple: true
  filter :created_at
  filter :updated_at

  { approve:  'approved',
    complete: 'completed',
    dismiss:  'dismissed',
    reject:   'rejected',
    abandon:  'abandoned'
  }.each do |action, state|
    batch_action action, if: proc { authorized?(action, Issue) } do |ids, inputs|
      authorize!(action, Issue)

      errors = []
      notices = []
      Issue.where(id: ids).find_each do |issue|
        begin
          issue.send("#{action}!")
          notices << "Issue #{issue.id} #{state}"
        rescue ActiveRecord::RecordInvalid => invalid
          errors <<
            if invalid.record.errors.full_messages.present?
              "Issue #{issue.id}: #{invalid.record.errors.full_messages.join('-')}" 
            else
              "Issue #{issue.id}: #{invalid.message}"
            end
        rescue AASM::InvalidTransition, StandardError => e
          errors << "Issue #{issue.id}: #{e.message}"
        end
      end
      flash[:error] = errors.join(', ') unless errors.empty?
      flash[:notice] = notices.join(', ') unless notices.empty?
      redirect_to dashboards_url
    end
  end

  order_by(:priority) do
    'priority desc, id desc'
  end

  index(title: '案 Issues Dashboard', row_class: ->(record) { 'top-priority' unless record.priority.zero? }) do
    selectable_column
    column(:priority)
    column(:id)  do |o|
      link_to o.id, [o.person, o]
    end
    column(:person) do |o|
      link_to o.person.person_info, o.person
    end
    column(:person_state) do |o|
      o.person.state
    end
    column :tpi, sortable: 'people.tpi' do |o|
      o.person.tpi
    end
    column(:reason) do |o|
      tags = o.tags.any? ? "(#{o.tags.pluck(:name).join(' - ')})" : ''
      "#{o.reason} #{tags}"
    end
    column(:person_tags) do |o|
      o.person.tags.pluck(:name).join(' - ')
    end
    column(:state)
    column(:created_at)
    column(:updated_at)
    column(:defer_until)
    column('')  do |o|
      link_to('Edit', edit_person_issue_url(o.person, o)) if o.editable?
    end
  end

  controller do
    def scoped_collection
      end_of_association_chain.includes(:person)
    end
  end
end
