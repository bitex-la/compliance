class Api::IssuesController < Api::ApiController
  before_action :validate_processable, only: [:create, :update] 
 
  def index
    page, per_page = Util::PageCalculator.call(params, 0, 10)
    issues = Issue.all.page(page).per(per_page)

    options = {}
    options[:meta] = { total_pages: (Issue.count.to_f / per_page).ceil }
    json_response JsonApi::ModelSerializer.call(issues, options), 200
  end

  def show
    begin 
      issue = Issue.find(params[:id])
      options = {}
      options[:include] = [
        :domicile_seed,
        :identification_seed,
        :natural_docket_seed,
        :legal_entity_docket_seed,
        :allowance_seeds
      ]
      jsonapi_response issue, options, 200
    rescue ActiveRecord::RecordNotFound
      errors = []
      errors << JsonApi::Error.new({
        links:   {},
        status:  404,
        code:    "issue_not_found",
        title:   "issue not found",
        detail:  "issue_not_found",
        source:  {},
        meta:    {}
      })
      error_response(errors)
    end
  end

  def create
    person = Person.find(params[:person_id])

    mapper = JsonapiMapper.doc params.permit!.to_h,
      issues: [
        :domicile_seed,
        :identification_seed,
	:natural_docket_seed,
	:legal_entity_docket_seed,
        :allowance_seeds,
        id: nil, 
	person_id: person.id   
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
        id: nil
      ],
      identification_seeds: [
        :kind,
        :number,
        :issuer,
        :attachments,
        id: nil
      ],
      natural_docket_seeds: [
        :first_name,
        :last_name,
        :birth_date,
        :nationality,
        :gender,
        :marital_status,
        :attachments,
        id: nil
      ],
      legal_entity_docket_seeds: [
        :industry,
        :business_description,
        :country,
        :commercial_name,
        :legal_name,
        :attachments,
        id: nil
      ],
      allowance_seeds: [
        :weight,
        :amount,
        :kind,
        :attachments,
        id: nil
      ],
      attachments: [
        :document,
        :document_file_name,
        :document_content_type,
        id: nil, 
	person_id: person.id
      ]
 
    if mapper.save_all
      jsonapi_response mapper.data, {include: [:people]}, 201
    else
      json_response mapper.all_errors, 422
    end	
  end

  def update
    begin
      issue = Issue.find(params[:id])
      options = {}
      options[:include] = [
        :domicile_seed,
        :identification_seed,
        :natural_docket_seed,
        :legal_entity_docket_seed,
        :allowance_seeds
      ]
      
      mapper = JsonapiMapper.doc params.permit!.to_h,
      issues: [
        :domicile_seed,
        :identification_seed,
	:natural_docket_seed,
	:legal_entity_docket_seed,
        :allowance_seeds,
        id: issue.id,
        person_id: issue.person.id 
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
        issue_id: issue.id
      ],
      identification_seeds: [
        :kind,
        :number,
        :issuer,
        :attachments,
        issue_id: issue.id
      ],
      natural_docket_seeds: [
        :first_name,
        :last_name,
        :birth_date,
        :nationality,
        :gender,
        :marital_status,
        :attachments,
        issue_id: issue.id
      ],
      legal_entity_docket_seeds: [
        :industry,
        :business_description,
        :country,
        :commercial_name,
        :legal_name,
        :attachments,
        issue_id: issue.id
      ],
      allowance_seeds: [
        :weight,
        :amount,
        :kind,
        :attachments,
        issue_id: issue.id
      ],
      attachments: [
        :document,
        :document_file_name,
        :document_content_type,
	person_id: issue.person.id
      ] 

      if mapper.save_all
        jsonapi_response mapper.data, options, 200
      else
        json_response mapper.all_errors, 422
      end	      

    rescue ActiveRecord::RecordNotFound
      errors = []
      errors << JsonApi::Error.new({
        links:   {},
        status:  404,
        code:    "issue_not_found",
        title:   "issue not found",
        detail:  "issue_not_found",
        source:  {},
        meta:    {}
      })
      error_response(errors)
    end 
  end
end
