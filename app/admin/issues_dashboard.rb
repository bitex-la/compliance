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
  scope :all

  filter :email_seeds_address_cont, label: "Email"
  filter :identification_seeds_number_or_argentina_invoicing_detail_seed_tax_id_or_chile_invoicing_detail_seed_tax_id_cont, label: "ID Number"
  filter :natural_docket_seed_first_name_cont, label: "First Name"
  filter :natural_docket_seed_last_name_cont,  label: "Last Name"
  filter :legal_entity_docket_seed_legal_name_or_legal_entity_docket_seed_commercial_name_cont, label: "Company Name"
  filter :note_seeds_title_or_note_seeds_body_cont, label: "Notes"
  filter :domicile_seeds_street_address_or_argentina_invoicing_detail_seed_address_cont, label: "Street Address"
  filter :domicile_seeds_street_number_or_argentina_invoicing_detail_seed_address_cont, label: "Street Number"
  filter :domicile_seeds_postal_code_or_argentina_invoicing_detail_seed_address_cont, label: "Postal Code"
  filter :natural_docket_seed_politically_exposed_eq, as: :select, label: "Is PEP"
  filter :created_at
  filter :updated_at


  index title: '案 Issues Dashboard' do
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
end
