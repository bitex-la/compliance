class Api::IssuesController < Api::ApiController
  caches_action :index, expires_in: 1.minute
  caches_action :show, expires_in: 1.minute

  def index
    page, per_page = Util::PageCalculator.call(params, 0, 3)
    issues = Person.find(params[:person_id]).issues
      .includes(*build_eager_load_list)
      .order(updated_at: :desc)
      .page(page)
      .per(per_page)

    options = {
      meta: { total_pages: (issues.count.to_f / per_page).ceil },
      include: Issue.included_for
    }
    jsonapi_response issues, options, 200
  end

  def show
    issue = Person
      .preload(*Person::eager_person_entities)
      .find(params[:person_id])
      .issues
      .preload(*Issue::eager_issue_entities)
      .find(params[:id])

    jsonapi_response(issue, {
      include: Issue.included_for
    }, 200)
  end

  def create
    person = Person.find(params[:person_id])
    mapper = get_issue_jsonapi_mapper(person.id)
    return jsonapi_422(nil) unless mapper.data

    if mapper.save_all
      expire_action :action => :index
      jsonapi_response mapper.data, {
        include: Issue.included_for
      }, 201
    else
      json_response mapper.all_errors, 422
    end
  end

  def update
    issue = Person
      .find(params[:person_id])
      .issues.find(params[:id])
    mapper = get_issue_jsonapi_mapper(issue.person.id, issue.id)
    return jsonapi_422(nil) unless mapper.data

    debugger
    if mapper.save_all
      expire_action :action => :index
      expire_action :action => :show
      jsonapi_response mapper.data, {
        include: Issue.included_for
      }, 200
    else
      json_response mapper.all_errors, 422
    end
  end

  private

  def build_eager_load_list
    [
      *Issue::eager_issue_entities,
      [observations: [:observation_reason]],
      [person: Person::eager_person_entities]
    ]
  end

  def get_issue_jsonapi_mapper(person_id, issue_id = nil)
    hash_params = params.permit!.to_h
    seed_scope = issue_id ? { issue_id: issue_id } : { id: nil }

    JsonapiMapper.doc_unsafe! params.permit!.to_h,
      [
        :people,
        :observation_reasons,
        :domiciles,
        :risk_scores,
        :identifications,
        :allowances,
        :fund_deposits,
        :phones,
        :emails,
        :notes,
        :affinities,
        :argentina_invoicing_details,
        :chile_invoicing_details,
        :natural_dockets,
        :legal_entity_dockets,
        :attachments
      ],
      issues: [
        :state,
        :risk_score_seeds,
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
      risk_score_seeds: [
        :score,
        :provider,
        :extra_info,
        :external_link,
        :attachments,
        :copy_attachments,
        :replaces,
        seed_scope
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
        :phone_kind_code,
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
        :email_kind_code,
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
        :affinity_kind_code,
        :related_person,
        :replaces,
        :attachments,
        :copy_attachments,
        seed_scope
      ],
      identification_seeds: [
        :identification_kind_code,
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
        :gender_code,
        :marital_status_code,
        :job_title,
        :job_description,
        :politically_exposed,
        :politically_exposed_reason,
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
        :vat_status_code,
        :tax_id,
        :tax_id_kind_code,
        :receipt_kind_code,
        :full_name,
        :country,
        :address,
        :attachments,
        :copy_attachments,
        seed_scope
      ],
      chile_invoicing_detail_seeds: [
        :vat_status_code,
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
        :kind_code,
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
      attachments: [
        :document,
        :document_file_name,
        :document_content_type,
        :attached_to_seed,
        person_id: person_id
      ],
      people: [],
      observation_reasons: [],
      domiciles: [],
      risk_scores: [],
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
      fund_deposits: []
  end
end
