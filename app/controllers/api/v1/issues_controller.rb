class Api::V1::IssuesController < Api::V1::ApiController
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
      json_response JsonApi::ModelSerializer.call(issue), 200
    rescue ActiveRecord::RecordNotFound
      json_response({ error: 'not found' }, 404)
    end
  end

  def create
    issue, errors = Issue::IssueCreator.call(params.permit!.to_h)
    if errors.empty?
      json_response JsonApi::ModelSerializer.call(issue), 201
    else
      error_data, status = JsonApi::ErrorsSerializer.call(errors)
      json_response error_data, status
    end
  end
end
