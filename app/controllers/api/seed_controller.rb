class Api::SeedController < Api::ApiController
  def index
    page, per_page = Util::PageCalculator.call(params, 0, 10)
    collection = resource_class.order(updated_at: :desc).page(page).per(per_page)

    jsonapi_response collection, options_for_response.merge!(
      meta: { total_pages: (resource.count.to_f / per_page).ceil })
  end

  def show
    jsonapi_response resource, options_for_response
  end

  def create
    map_and_save(201)
  end

  def update
    resource
    map_and_save(200)
  end

  protected

  def resource
    resource_class.find(params[:id])
  end

  def map_and_save(success_code)
    mapper = get_mapper
    return jsonapi_422(nil) unless mapper.data

    if mapper.save_all
      jsonapi_response mapper.data, options_for_response, success_code
    else
      json_response mapper.all_errors, 422
    end
  end

  def options_for_response
    {}
  end

  def get_mapper
    mapper = JsonapiMapper.doc_unsafe!(params.permit!.to_h,
      %w(issues domicile_seeds phone_seeds email_seeds note_seeds
        affinity_seeds identification_seeds natural_docket_seeds risk_score_seeds
        legal_entity_docket_seeds argentina_invoicing_detail_seeds
        chile_invoicing_detail_seeds allowance_seeds observations attachments
        people observation_reasons domiciles identifications allowances phones
        emails notes affinities argentina_invoicing_details chile_invoicing_details
        natural_dockets legal_entity_dockets risk_scores fund_deposits
      ),
      issues: [
        :state,
        :domicile_seeds,
        :identification_seeds,
        :risk_score_seeds,
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
        :person,
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
        :issue
      ],
      risk_score_seeds: [
        :score,
        :provider,
        :extra_info,
        :external_link,
        :attachments,
        :copy_attachments,
        :replaces,
        :issue
      ],
      phone_seeds: [
        :number,
        :phone_kind_code,
        :country,
        :has_whatsapp,
        :has_telegram,
        :note,
        :attachments,
        :copy_attachments,
        :replaces,
        :issue
      ],
      email_seeds: [
        :address,
        :email_kind_code,
        :attachments,
        :copy_attachments,
        :replaces,
        :issue
      ],
      note_seeds: [
        :title,
        :body,
        :attachments,
        :copy_attachments,
        :replaces,
        :issue
      ],
      affinity_seeds: [
        :affinity_kind_code,
        :related_person,
        :replaces,
        :attachments,
        :copy_attachments,
        :issue
      ],
      identification_seeds: [
        :identification_kind_code,
        :number,
        :issuer,
        :attachments,
        :copy_attachments,
        :replaces,
        :issue
      ],
      natural_docket_seeds: [
        :first_name,
        :last_name,
        :birth_date,
        :nationality,
        :gender_code,
        :marital_status_code,
        :job_title,
        :job_description,
        :politically_exposed,
        :politically_exposed_reason,
        :attachments,
        :copy_attachments,
        :issue
      ],
      legal_entity_docket_seeds: [
        :industry,
        :business_description,
        :country,
        :commercial_name,
        :legal_name,
        :attachments,
        :copy_attachments,
        :issue
      ],
      argentina_invoicing_detail_seeds: [
        :vat_status_code,
        :tax_id,
        :tax_id_kind_code,
        :receipt_kind_code,
        :full_name,
        :country,
        :address,
        :attachments,
        :copy_attachments,
        :issue
      ],
      chile_invoicing_detail_seeds: [
        :vat_status_code,
        :tax_id,
        :giro,
        :ciudad,
        :comuna,
        :attachments,
        :copy_attachments,
        :issue
      ],
      allowance_seeds: [
        :weight,
        :amount,
        :kind_code,
        :attachments,
        :copy_attachments,
        :replaces,
        :issue
      ],
      observations: [
        :note,
        :reply,
        :scope,
        :observation_reason,
        :issue
      ],
      attachments: [
        :document,
        :document_file_name,
        :document_file_size,
        :document_content_type,
        :attached_to_seed,
        :attached_to_seed_id,
        :attached_to_seed_type,
        :person,
      ],
      people: [],
      observation_reasons: [],
      domiciles: [],
      identifications: [],
      natural_dockets: [],
      legal_entity_dockets: [],
      risk_scores: [],
      phones: [],
      emails: [],
      notes: [],
      affinities: [],
      argentina_invoicing_details: [],
      chile_invoicing_details: [],
      allowances: [],
      fund_deposits: []
    )

    mapper
  end
end
