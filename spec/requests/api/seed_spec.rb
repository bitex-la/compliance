require 'rails_helper'
require 'helpers/api/issues_helper'
require 'helpers/api/api_helper'
require 'json'

shared_examples 'seed' do |type, has_many, initial_factory, later_factory|
  initial_seed = "#{initial_factory}_seed"
  later_seed = "#{later_factory}_seed"
  seed_type = Garden::Naming.new(type).seed_plural

  it "Creates, updates and approves #{seed_type}" do
    issue = create(:basic_issue)
    person = issue.person

    initial_attrs = attributes_for(initial_seed)

    api_create "/#{seed_type}", {
      type: seed_type,
      attributes: initial_attrs,
      relationships: {
        issue: { data: { id: issue.id, type: 'issues' } }
      }
    }

    seed_id = api_response.data.id

    api_response.data.attributes.to_h.slice(*initial_attrs.keys)
                .should eq(initial_attrs)

    later_attrs = attributes_for(later_seed)

    api_update "/#{seed_type}/#{seed_id}", {
      type: seed_type,
      attributes: later_attrs
    }

    # Puts an attachment in it too.

    api_response.data.attributes.to_h.slice(*later_attrs.keys)
                .should eq(later_attrs)

    api_request :post, "/issues/#{issue.id}/approve"

    api_get "/people/#{person.id}"

    api_response.included
                .find { |i| i.type == type.to_s }
                .attributes
                .to_h
                .slice(*later_attrs.keys)
                .should == later_attrs
  end

  it "Updates #{type} via issue" do
    person = create(:empty_person).reload
    create(:basic_issue, person: person, aasm_state: 'approved')
    replaced = create(initial_factory, person: person)

    issue = create(:basic_issue, person: person)
    attrs = attributes_for(initial_seed)

    relationships = { issue: { data: { id: issue.id, type: 'issues' } } }
    if has_many
      relationships[:replaces] = { data: { id: replaced.id, type: type } }
    end

    api_create "/#{seed_type}", {
      type: seed_type,
      attributes: attrs,
      relationships: relationships
    }

    api_request :post, "/issues/#{issue.id}/approve"

    api_get "/people/#{person.id}"

    docket = api_response.included.find { |i| i.type == type.to_s }

    replaced.reload.replaced_by_id.should eq(docket.id.to_i)

    docket.attributes.to_h.slice(*attrs.keys).should == attrs
  end
end

describe 'All seed and fruit kinds' do
  it_behaves_like('seed', :natural_dockets, false,
                  :full_natural_docket, :alt_full_natural_docket)

  it_behaves_like('seed', :legal_entity_dockets, false,
                  :full_legal_entity_docket, :alt_full_legal_entity_docket)

  it_behaves_like('seed', :argentina_invoicing_details, true,
                  :full_argentina_invoicing_detail,
                  :alt_full_argentina_invoicing_detail)

  it_behaves_like('seed', :chile_invoicing_details, true,
                  :full_chile_invoicing_detail, :alt_full_chile_invoicing_detail)

  it_behaves_like('seed', :phones, true, :full_phone, :alt_full_phone)

  it_behaves_like('seed', :domiciles, true, :full_domicile, :alt_full_domicile)

  it_behaves_like('seed', :emails, true, :full_email, :alt_full_email)

  it_behaves_like('seed', :identifications, true,
                  :full_natural_person_identification,
                  :alt_full_natural_person_identification)

  it_behaves_like('seed', :allowances, true, :salary_allowance,
                  :alt_salary_allowance)

  it_behaves_like('seed', :risk_scores, true, :full_risk_score,
                  :alt_full_risk_score)

=begin
  AffinitySeed
  NoteSeed
=end
end

describe "when creating updating and approving" do
  it "Can create more than one" do
    pending
    fail
  end

  it "Cannot create more than one" do
    pending
    fail
  end

  it "Can add attachments" do
    pending
    fail
  end

  it "Can't add attachments once issue is closed" do
    pending
    fail
  end

  it "Can't edit once issue is closed" do
    pending
    fail
  end

  it "Allows filtering and showing fruit" do
    pending
    fail
  end

  it "Allows filtering and showing seed" do
    pending
    fail
  end
end
