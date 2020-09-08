#encoding: utf-8
ActiveAdmin.register Issue, as: "Dashboard" do
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
  filter :legal_entity_docket_seed_legal_name_or_legal_entity_docket_seed_commercial_name_cont, label: "Company Name"
  filter :by_person_type, as: :select, collection: Person.person_types
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

  batch_action :approve do |ids, inputs|
    errors = []
    Issue.find(ids).each do |issue|
      unless issue.all_workflows_performed?
        errors << "Not all workflows has been performed for Issue #{issue.id}"
        next
      end
      unless authorized?(:approve, issue)
        errors << "You might have not permission to approve Issue #{issue.id}"
        next
      end
      unless issue.may_approve?
        errors << "Issue #{issue.id} can't be approved"
        next
      end
      unless issue.state != 'approve'
        errors << "Issue #{issue.id} previously approved"
        next
      end
      begin
        issue.approve!
      rescue ActiveRecord::RecordInvalid => invalid
        errors << invalid.record.errors.full_messages.join('-') unless invalid.record.errors.full_messages.empty?
      rescue AASM::InvalidTransition => e
        errors << e.message
      end
    end
    flash[:error] = errors.joins(', ')
    redirect_to :back
  end

  index title: '案 Issues Dashboard' do
    selectable_column
    column(:id)  do |o|
      link_to o.id, [o.person, o]
    end
    column(:person) do |o|
      link_to o.person.person_info, o.person
    end
    column(:person_state) do |o|
      o.person.state
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
end