require 'rails_helper'
require 'helpers/api/issues_helper'
require 'json'

PLURAL_SEEDS = %w(
  AffinitySeed
  PhoneSeed
  DomicileSeed
  EmailSeed
  IdentificationSeed
  AllowanceSeed
  NoteSeed
)

SINGULAR_SEEDS = %w(
  NaturalDocketSeed
  LegalEntityDocketSeed
  ArgentinaInvoicingDetailSeed
  ChileInvoicingDetailSeed
)

ALL_SEEDS = PLURAL_SEEDS + SINGULAR_SEEDS

def build_seed_payload(seed)
  if seed == 'AffinitySeed'
    related_person = create(:empty_person)
    related_person.save
    Api::SeedsHelper.affinity_seed(issue, related_person, :png)
  else
    Api::SeedsHelper.send(seed.underscore.to_sym, issue, :png)
  end
end

def assert_seed_update(admin_user, issue, seed_name, seed_id, relationship, payload)
  case seed_name
    when 'NaturalDocketSeed'
      payload[:data][:attributes][:first_name] = 'Zinedine'
      payload[:data][:attributes][:last_name] = 'Zidane'
    when 'LegalEntityDocketSeed'
      payload[:data][:attributes][:commercial_name] = 'E Crop'
      payload[:data][:attributes][:legal_name] = 'Evil Corp'
    when 'ArgentinaInvoicingDetailSeed'
      payload[:data][:attributes][:name] = 'Nick Ocean'
      payload[:data][:attributes][:address] = 'Fake Street 123'
    when 'ChileInvoicingDetailSeed'
      payload[:data][:attributes][:ciudad] = 'Valparaiso'
      payload[:data][:attributes][:comuna] = 'La Rosita'
    when 'AffinitySeed'
      payload[:data][:attributes][:affinity_kind] = 'manager'
    when 'DomicileSeed'
      payload[:data][:attributes][:street_address] = 'Cerati'
      payload[:data][:attributes][:street_number] = '100'
    when 'IdentificationSeed'
      payload[:data][:attributes][:number] = '95678431'
      payload[:data][:attributes][:issuer] = 'AR'
    when 'PhoneSeed'
      payload[:data][:attributes][:number] = '+573014825346'
      payload[:data][:attributes][:country] = 'CO'
    when 'EmailSeed'
      payload[:data][:attributes][:address] = 'zinedine@soccer.com'
      payload[:data][:attributes][:email_kind] = 'personal'
    when 'NoteSeed'
      payload[:data][:attributes][:title] = 'My nickname'
      payload[:data][:attributes][:body] = 'Call me zizu'
    when 'AllowanceSeed'
      payload[:data][:attributes][:weight] = 1000
      payload[:data][:attributes][:kind] = 'USD'
  end

  put "/api/people/#{issue.person.id}/issues/#{issue.id}/#{seed_name.pluralize.underscore}/#{seed_id}",
    params: JSON.dump(payload),
    headers: {
      'CONTENT_TYPE': 'application/json',
      'Authorization': "Token token=#{admin_user.api_token}" }

  assert_response 200

  issue.reload
  case seed_name
    when 'NaturalDocketSeed'
      issue.natural_docket_seed.first_name.should == 'Zinedine'
      issue.natural_docket_seed.last_name.should == 'Zidane'
    when 'LegalEntityDocketSeed'
      issue.legal_entity_docket_seed.commercial_name.should == 'E Crop'
      issue.legal_entity_docket_seed.legal_name.should == 'Evil Corp'
    when 'ArgentinaInvoicingDetailSeed'
      issue.argentina_invoicing_detail_seed.name.should == 'Nick Ocean'
      issue.argentina_invoicing_detail_seed.address.should == 'Fake Street 123'
    when 'ChileInvoicingDetailSeed'
      issue.chile_invoicing_detail_seed.ciudad.should == 'Valparaiso'
      issue.chile_invoicing_detail_seed.comuna.should == 'La Rosita'
    when 'AffinitySeed'
      issue.affinity_seeds.first.affinity_kind.should  == :manager
    when 'DomicileSeed'
      issue.domicile_seeds.first.street_address.should == 'Cerati'
      issue.domicile_seeds.first.street_number.should == '100'
    when 'IdentificationSeed'
      issue.identification_seeds.first.number.should == '95678431'
      issue.identification_seeds.first.issuer.should == 'AR'
    when 'PhoneSeed'
      issue.phone_seeds.first.number.should == '+573014825346'
      issue.phone_seeds.first.country.should == 'CO'
    when 'EmailSeed'
      issue.email_seeds.first.address.should == 'zinedine@soccer.com'
      issue.email_seeds.first.email_kind.should == :personal
    when 'NoteSeed'
      issue.note_seeds.first.title.should == 'My nickname'
      issue.note_seeds.first.body.should == 'Call me zizu'
    when 'AllowanceSeed'
      issue.allowance_seeds.first.weight.should == 1000
      issue.allowance_seeds.first.kind.should == 'USD'
  end
end

ALL_SEEDS.each do |seed|
  describe seed.constantize do
    let(:issue) {create(:basic_issue)}
    let(:admin_user) { create(:admin_user) }

    describe "Creating a new #{seed}" do
      it "creates a new #{seed} with an attachment" do
        seed_payload = build_seed_payload(seed)

        relationship = if PLURAL_SEEDS.include? seed
            seed.pluralize.underscore
          else
            seed.underscore
          end

        post "/api/people/#{issue.person.id}/issues/#{issue.id}/#{seed.pluralize.underscore}",
          params: seed_payload,
          headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

        assert_response 201
        if PLURAL_SEEDS.include? seed
          issue.send("#{relationship}").count.should == 1
          issue.send("#{relationship}").first.attachments.count.should == 1
        else
          issue.send("#{relationship}").should_not be_nil
          issue.send("#{relationship}").attachments.count.should == 1
        end
      end
    end

    describe "Updating a new #{seed}" do
      it "creates, gets and updates a new #{seed} with an attachment" do
        seed_payload = build_seed_payload(seed)

        relationship = if PLURAL_SEEDS.include? seed
            seed.pluralize.underscore
          else
            seed.underscore
          end

        post "/api/people/#{issue.person.id}/issues/#{issue.id}/#{seed.pluralize.underscore}",
          params: seed_payload,
          headers: { 'Authorization': "Token token=#{admin_user.api_token}" }
        assert_response 201

        seed_id = if PLURAL_SEEDS.include? seed
          issue.send("#{relationship}").first.id
        else
          issue.send("#{relationship}").id
        end

        # For plural seeds show endpoint exists, otherwise goes to seed index
        if PLURAL_SEEDS.include? seed
          get "/api/people/#{issue.person.id}/issues/#{issue.id}/#{seed.pluralize.underscore}/#{seed_id}",
            headers: { 'Authorization': "Token token=#{admin_user.api_token}" }
        else
          get "/api/people/#{issue.person.id}/issues/#{issue.id}/#{seed.pluralize.underscore}",
            headers: { 'Authorization': "Token token=#{admin_user.api_token}" }
        end
        assert_response 200

        seed_payload = JSON.parse(response.body).deep_symbolize_keys

        assert_seed_update(admin_user, issue, seed, seed_id, relationship, seed_payload)
      end
    end
  end
end
