class Api::IssuesController < Api::ApiController
  def index
    page, per_page = Util::PageCalculator.call(params, 0, 10)
    issues = Issue.all.page(page).per(per_page)
    options = { meta: { total_pages: (Issue.count.to_f / per_page).ceil } }
    jsonapi_response issues, options, 200
  end

  def show
    issue = Person.find(params[:person_id]).issues.find(params[:id])
    jsonapi_response(issue, {}, 200)
  end

  def create
    person = Person.find(params[:person_id])
    mapper = get_issue_jsonapi_mapper(person.id)
    return jsonapi_422(nil) unless mapper.data

    if mapper.save_all
      jsonapi_response mapper.data, {}, 201
    else
      json_response mapper.all_errors, 422
    end	
  end

  def update
    issue = Person.find(params[:person_id]).issues.find(params[:id])
    mapper = get_issue_jsonapi_mapper(issue.person.id, issue.id)
    return jsonapi_422(nil) unless mapper.data

    if mapper.save_all
      jsonapi_response mapper.data, {}, 200
    else
      json_response mapper.all_errors, 422
    end	      
  end

  private

  def get_issue_jsonapi_mapper(person_id, issue_id = nil)
    hash_params = params.permit!.to_h
    seed_scope = issue_id ? { issue_id: issue_id } : { id: nil }

    JsonapiMapper.doc_unsafe! params.permit!.to_h,
      [
        :people,
        :observation_reasons, 
        :domiciles, 
        :identifications, 
        :allowances, 
        :phones, 
        :emails,
        :notes,
        :affinities,
        :argentina_invoicing_details,
        :chile_invoicing_details,
        :natural_dockets,
        :legal_entity_dockets,
      ],
      issues: [
        :domicile_seeds,
        :identification_seeds,
        :natural_docket_seed,
        :legal_entity_docket_seed,
        :argentina_invoicing_detail_seed,
        :chile_invoicing_detail_seed,
        :allowance_seeds,
        :phone_seeds,
        :email_seeds,
        :note_seeds,
        :affinity_seeds,
        :observations,
        id: issue_id, 
        person_id: person_id
      ], 
      domicile_seeds: [
        :country,
        :state,
        :city,
        :street_address,
        :street_number,
        :postal_code,
        :floor,
        :apartment,
        :attachments,
        :copy_attachments,
        :replaces,
        seed_scope
      ],
      phone_seeds: [
        :number,
        :kind,
        :country,
        :has_whatsapp,
        :has_telegram,
        :note,
        :attachments,
        :copy_attachments,
        :replaces,
        seed_scope
      ],
      email_seeds: [
        :address,
        :kind,
        :attachments,
        :copy_attachments,
        :replaces,
        seed_scope
      ],
      note_seeds: [
        :title,
        :body,
        :attachments,
        :copy_attachments,
        :replaces,
        seed_scope
      ],
      affinity_seeds: [
        :kind,
        :related_person,
        :replaces,
        :attachments,
        :copy_attachments,
        seed_scope
      ],
      identification_seeds: [
        :kind,
        :number,
        :issuer,
        :attachments,
        :copy_attachments,
        :replaces,
        seed_scope
      ],
      natural_docket_seeds: [
        :first_name,
        :last_name,
        :birth_date,
        :nationality,
        :gender,
        :marital_status,
        :attachments,
        :copy_attachments,
        seed_scope
      ],
      legal_entity_docket_seeds: [
        :industry,
        :business_description,
        :country,
        :commercial_name,
        :legal_name,
        :attachments,
        :copy_attachments,
        seed_scope
      ],
      argentina_invoicing_detail_seeds: [
        :vat_status_id,
        :tax_id,
        :tax_id_type,
        :receipt_type,
        :name,
        :country,
        :address,
        :attachments,
        :copy_attachments,
        seed_scope
      ],
      chile_invoicing_detail_seeds: [
        :vat_status_id,
        :tax_id,
        :giro,
        :ciudad,
        :comuna,
        :attachments,
        :copy_attachments,
        seed_scope
      ],
      allowance_seeds: [
        :weight,
        :amount,
        :kind,
        :attachments,
        :copy_attachments,
        :replaces,
        seed_scope
      ],
      observations: [
        :note,
        :reply,
        :scope,
        :observation_reason,
        seed_scope
      ],
      people: [],
      observation_reasons: [],
      domiciles: [],
      identifications: [],
      natural_dockets: [],
      legal_entity_dockets: [],
      phones: [],
      emails: [],
      notes: [],
      affinities: [], 
      argentina_invoicing_details: [],
      chile_invoicing_details: [],
      allowances: [],
      attachments: [
        :document,
        :document_file_name,
        :document_content_type,
        person_id: person_id
      ]
  end
end
