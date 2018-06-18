require 'rails_helper'
require 'helpers/api/issues_helper'
require 'helpers/api/api_helper'
require 'json'

def assert_seed_update(admin_user, issue, seed_name, seed_id, relationship, payload)
  attrs = payload[:data][:attributes]
  case seed_name
    when 'NaturalDocketSeed'
      attrs[:first_name] = 'Zinedine'
      attrs[:last_name] = 'Zidane'
    when 'LegalEntityDocketSeed'
      attrs[:commercial_name] = 'E Crop'
      attrs[:legal_name] = 'Evil Corp'
    when 'ArgentinaInvoicingDetailSeed'
      attrs[:name] = 'Nick Ocean'
      attrs[:address] = 'Fake Street 123'
    when 'ChileInvoicingDetailSeed'
      attrs[:ciudad] = 'Valparaiso'
      attrs[:comuna] = 'La Rosita'
    when 'AffinitySeed'
      attrs[:affinity_kind] = 'manager'
    when 'DomicileSeed'
      attrs[:street_address] = 'Cerati'
      attrs[:street_number] = '100'
    when 'IdentificationSeed'
      attrs[:number] = '95678431'
      attrs[:issuer] = 'AR'
    when 'PhoneSeed'
      attrs[:number] = '+573014825346'
      attrs[:country] = 'CO'
    when 'EmailSeed'
      attrs[:address] = 'zinedine@soccer.com'
      attrs[:email_kind] = 'personal'
    when 'NoteSeed'
      attrs[:title] = 'My nickname'
      attrs[:body] = 'Call me zizu'
    when 'AllowanceSeed'
      attrs[:weight] = 1000
      attrs[:kind] = 'USD'
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
    let(:relationship) do 
      PLURAL_SEEDS.include?(seed) ? seed.pluralize.underscore : seed.underscore
    end

    describe "Creating a new #{seed}" do
      it "creates a new #{seed} with an attachment" do
        seed_payload = build_seed_payload(seed)

        post "/api/people/#{issue.person.id}/issues/#{issue.id}/#{seed.pluralize.underscore}",
          params: seed_payload,
          headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

        assert_response 201

        issue.reload
        if PLURAL_SEEDS.include? seed
          issue.send(relationship).count.should == 1
          issue.send(relationship).first.attachments.count.should == 1
        else
          issue.send(relationship).should_not be_nil
          issue.send(relationship).attachments.count.should == 1
        end
      end

      it "cannot create more than one seed for singular, othewise must add a new one to collection" do
        seed_payload = build_seed_payload(seed)

        post "/api/people/#{issue.person.id}/issues/#{issue.id}/#{seed.pluralize.underscore}",
          params: seed_payload,
          headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

        assert_response 201
        
        issue.reload
        if PLURAL_SEEDS.include? seed
          issue.send(relationship).count.should == 1
          issue.send(relationship).first.attachments.count.should == 1
        else
          issue.send(relationship).should_not be_nil
          issue.send(relationship).attachments.count.should == 1
        end

        seed_payload = build_seed_payload(seed)

        post "/api/people/#{issue.person.id}/issues/#{issue.id}/#{seed.pluralize.underscore}",
          params: seed_payload,
          headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

        if PLURAL_SEEDS.include? seed
          assert_response 201  
          issue.send(relationship).count.should == 2
        else
          issue.send(relationship).should_not be_nil
          assert_response 422
        end
      end
    end

    describe "Updating a new #{seed}" do
      it "creates, gets and updates a new #{seed} with an attachment" do
        seed_payload = build_seed_payload(seed)

        post "/api/people/#{issue.person.id}/issues/#{issue.id}/#{seed.pluralize.underscore}",
          params: seed_payload,
          headers: { 'Authorization': "Token token=#{admin_user.api_token}" }
        assert_response 201

        issue.reload
        seed_id = if PLURAL_SEEDS.include? seed
          issue.send(relationship).first.id
        else
          issue.send(relationship).id
        end

        # For plural seeds show endpoint exists, otherwise goes to seed index
        get "/api/people/#{issue.person.id}/issues/#{issue.id}/#{seed.pluralize.underscore}/#{seed_id}",
          headers: { 'Authorization': "Token token=#{admin_user.api_token}" }

        assert_response 200

        seed_payload = JSON.parse(response.body).deep_symbolize_keys

        assert_seed_update(admin_user, issue, seed, seed_id, relationship, seed_payload)
      end
    end
  end
end
