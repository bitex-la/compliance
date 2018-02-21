class Api::ApiController < ApplicationController
  include ApiResponse

  # ToDo: Deprecate and use mapper.
  def validate_processable
    if params[:data].blank?
      errors = []

      errors << JsonApi::Error.new({
        links:   {},
        status:  422,
        code:    "data_not_found",
        title:   "Missing `data` Member at document's top level",
        detail:  "Missing `data` Member at document's top level",
        source:  { },
        meta:    {}
      })  
      error_data, status = JsonApi::ErrorsSerializer.call(errors)
      json_response error_data, status
    end  
  end
end
