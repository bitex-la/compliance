class Api::IssuesController < Api::ApiController
  before_action :validate_processable, only: [:create, :update]
  protect_from_forgery :except => [:create]

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
        :domicile_seeds,
        :identification_seeds,
        :natural_docket_seeds,
        :legal_entity_docket_seeds,
        :allowance_seeds
      ]
      json_response JsonApi::ModelSerializer.call(issue, options), 200
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
    issue, errors = Issue::IssueCreator.call(params.permit!.to_h)
    if errors.empty?
      json_response JsonApi::ModelSerializer.call(issue), 201
    else
      error_response(errors)
    end
  end
end
