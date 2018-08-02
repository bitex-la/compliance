class Api::IssuesController < Api::ApiController
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
      .preload(*eager_person_entities)
      .find(params[:person_id])
      .issues
      .preload(*eager_issue_entities)
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

    if mapper.save_all
      jsonapi_response mapper.data, {
        include: Issue.included_for
      }, 200
    else
      json_response mapper.all_errors, 422
    end
  end

  private

  SEEDS = %w[
    natural_docket_seed
    legal_entity_docket_seed
    argentina_invoicing_detail_seed
    chile_invoicing_detail_seed
    affinity_seeds
    allowance_seeds
    domicile_seeds
    email_seeds
    phone_seeds
    risk_score_seeds
    fund_deposit_seeds
    identification_seeds
    note_seeds
  ]

  FRUITS = %w[
    natural_dockets
    legal_entity_dockets
    argentina_invoicing_details
    chile_invoicing_details
    affinities
    allowances
    domiciles
    emails
    phones
    risk_scores
    fund_deposits
    identifications
    notes
  ]

  def build_eager_load_list
    [
      *eager_issue_entities,
      [observations: [:observation_reason]],
      [person: eager_person_entities]
    ]
  end

  def eager_issue_entities
    entities = []
    SEEDS.each do |seed|
      entities.push(["#{seed}": eager_seed_entities])
    end
    entities
  end

  def eager_person_entities
    entities = []
    FRUITS.each do |fruit|
      entities.push("#{fruit}": eager_fruit_entities)
    end
    entities
  end

  def eager_seed_entities
    [:person, :fruit , attachments:[:attached_to_fruit, :attached_to_seed]]
  end

  def eager_fruit_entities
    [:seed , attachments:[:attached_to_fruit, :attached_to_seed]]
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
        :fund_deposit_seeds,
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
      fund_deposit_seeds: [
        :amount,
        :currency,
        :deposit_method,
        :external_id,
        :attachments,
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
        :phone_kind,
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
        :email_kind,
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
        :affinity_kind,
        :related_person,
        :replaces,
        :attachments,
        :copy_attachments,
        seed_scope
      ],
      identification_seeds: [
        :identification_kind,
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
        :vat_status,
        :tax_id,
        :tax_id_kind,
        :receipt_kind,
        :name,
        :country,
        :address,
        :attachments,
        :copy_attachments,
        seed_scope
      ],
      chile_invoicing_detail_seeds: [
        :vat_status,
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
      attachments: [
        :document,
        :document_file_name,
        :document_content_type,
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
