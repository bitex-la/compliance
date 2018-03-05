class Api::IssuesController < Api::ApiController
  def index
    page, per_page = Util::PageCalculator.call(params, 0, 10)
    issues = Issue.all.page(page).per(per_page)
    options = { meta: { total_pages: (Issue.count.to_f / per_page).ceil } }
    jsonapi_response issues, options, 200
  end

  def show
    jsonapi_response(Issue.find(params[:id]), {}, 200)
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
    seed_scope = issue_id ? { issue_id: issue_id } : { id: nil }

    JsonapiMapper.doc params.permit!.to_h,
      issues: [
        :domicile_seed,
        :identification_seed,
        :natural_docket_seed,
        :legal_entity_docket_seed,
        :allowance_seeds,
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
        seed_scope
      ],
      identification_seeds: [
        :kind,
        :number,
        :issuer,
        :attachments,
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
        seed_scope
      ],
      legal_entity_docket_seeds: [
        :industry,
        :business_description,
        :country,
        :commercial_name,
        :legal_name,
        :attachments,
        seed_scope
      ],
      allowance_seeds: [
        :weight,
        :amount,
        :kind,
        :attachments,
        seed_scope
      ],
      observations: [
        :note,
        :reply,
        :scope,
        seed_scope
      ],
      attachments: [
        :document,
        :document_file_name,
        :document_content_type,
        person_id: person_id
      ]
  end
end
