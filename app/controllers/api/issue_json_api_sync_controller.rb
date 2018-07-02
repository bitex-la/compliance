class Api::IssueJsonApiSyncController < Api::ApiController
  def show
    jsonapi_response get_resource(scope), options_for_response
  end

  def create
    map_and_save(201)
  end

  def update
    get_resource(scope)
    map_and_save(200)
  end

  def get_resource(scope)
  end

  protected

  def scoped_collection(&block)
    page, per_page = Util::PageCalculator.call(params, 0, 10)
    resource = block.call(scope)
      .order(updated_at: :desc).page(page).per(per_page)

    jsonapi_response resource, options_for_response.merge!(
      meta: { total_pages: (resource.count.to_f / per_page).ceil })
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

  def person
    @person ||= Person.find(params[:person_id])
  end

  def issue
    @issue ||= person.issues.find(params[:issue_id])
  end

  def scope
    issue
  end

  def get_mapper
    mapper = JsonapiMapper.doc_unsafe!(params.permit!.to_h,
      %w(issues domicile_seeds phone_seeds email_seeds note_seeds
        affinity_seeds identification_seeds natural_docket_seeds
        legal_entity_docket_seeds argentina_invoicing_detail_seeds
        chile_invoicing_detail_seeds allowance_seeds observations attachments
        people observation_reasons domiciles identifications allowances phones
        emails notes affinities argentina_invoicing_details chile_invoicing_details
        natural_dockets legal_entity_dockets
      ),
      issues: [
        :state,
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
      phone_seeds: [
        :number,
        :phone_kind,
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
        :email_kind,
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
        :affinity_kind,
        :related_person,
        :replaces,
        :attachments,
        :copy_attachments,
        :issue
      ],
      identification_seeds: [
        :identification_kind,
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
        :gender,
        :marital_status,
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
        :vat_status,
        :tax_id,
        :tax_id_kind,
        :receipt_kind,
        :name,
        :country,
        :address,
        :attachments,
        :copy_attachments,
        :issue
      ],
      chile_invoicing_detail_seeds: [
        :vat_status,
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
        :kind,
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
      phones: [],
      emails: [],
      notes: [],
      affinities: [],
      argentina_invoicing_details: [],
      chile_invoicing_details: [],
      allowances: []
    )

    if mapper.data.is_a?(Issue) || mapper.data.is_a?(Attachment)
      mapper.data.person = person
    elsif mapper.data.class.name.include? 'Seed'
      mapper.data.issue = issue
    end

    mapper.included do |i|
      if i.is_a?(Issue) || mapper.data.is_a?(Attachment)
        i.person = person
      elsif mapper.data.class.name.include? 'Seed'
        i.issue = issue
      end
    end
    mapper
  end
end
