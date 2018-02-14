class Api::V1::ApiController < ApplicationController
  include ApiResponse

  def validate_processable
    if params[:data].blank?
      error = JsonApi::Error.new
      error.source = {}
      error.detail = "Missing `data` Member at document's top level."
    
      json_response JsonApi::ErrorsSerializer.call(error), 422
    end  
  end
end