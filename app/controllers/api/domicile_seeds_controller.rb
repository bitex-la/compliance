class Api::DomicileSeedsController < Api::ApiController
  def index
    page, per_page = Util::PageCalculator.call(params, 0, 10)
    domicile_seeds = Person.find(params[:person_id])
      .issues.find(params[:issue_id])
      .domicile_seeds
      .order(updated_at: :desc).page(page).per(per_page)

    options = { meta: { total_pages: (domicile_seeds.count.to_f / per_page).ceil } }
    jsonapi_response domicile_seeds, options, 200
  end

  def show
    domicile_seed = Person.find(params[:person_id])
      .issues.find(params[:issue_id])
      .domicile_seeds.find(params[:id])

    jsonapi_response(domicile_seed, {}, 200)
  end

  def create
    person = Person.find(params[:person_id])
    issue = Issue.find(params[:issue_id])
    mapper = get_issue_jsonapi_mapper(person.id, issue.id)

    return jsonapi_422(nil) unless mapper.data

    if mapper.save_all
      jsonapi_response mapper.data, {}, 201
    else
      json_response mapper.all_errors, 422
    end
  end

  def update
    person = Person.find(params[:person_id])
    issue = Issue.find(params[:issue_id])
    domicile_seed = DomicileSeed.find(params[:id])
    mapper = get_issue_jsonapi_mapper(person.id, issue.id, domicile_seed.id)

    return jsonapi_422(nil) unless mapper.data

    if mapper.save_all
      jsonapi_response mapper.data, {}, 200
    else
      json_response mapper.all_errors, 422
    end
  end

  private

  def get_issue_jsonapi_mapper(person_id, issue_id, seed_id = nil)
    hash_params = params.permit!.to_h
    seed_scope = seed_id ? { seed_id: seed_id } : { id: nil }

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
        id: seed_id,
        issue_id: issue_id
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
