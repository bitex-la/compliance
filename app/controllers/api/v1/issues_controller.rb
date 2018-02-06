class Api::V1::IssuesController < ApplicationController
  protect_from_forgery :except => [:create]

  def index
    options = {}
    options[:meta] = { total: Issue.count }
    render json: IssueSerializer.new(Issue.all, options).serialized_json
  end

  def show
    issue = Issue.find(params[:id])
    render json: IssueSerializer.new(issue).serialized_json
  end

  def create
    issue = Issue.new(issue_params)
    issue.save
    render json: IssueSerializer.new(issue).serialized_json, status: 201
  end

  def issue_params
    # TODO: set the only: and except: values
    ActiveModelSerializers::Deserialization.jsonapi_parse(params)
  end
end
