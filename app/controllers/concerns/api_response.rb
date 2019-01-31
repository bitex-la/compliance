module ApiResponse
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordInvalid, with: :jsonapi_422
    rescue_from ActiveRecord::RecordNotFound, with: :jsonapi_404
  end

  def json_response(object, status = 200)
    render json: object, status: status
  end

  def jsonapi_public_response(it, options = {}, status = 200)
    jsonapi_response(it, options, status, true)
  end

  def jsonapi_response(it, options = {}, status = 200, public = false)
    options = params
      .permit!.to_h
      .deep_symbolize_keys
      .slice(:fields, :include)
      .merge(options)

    if options[:fields]
      options[:fields].each do |k,v|
        options[:fields][k] = v.split(',')
      end
    end

    if options[:include] && options[:include].is_a?(String)
      options[:include] = options[:include].split(',')
    end

    payload = it.is_a?(Array) ? it.first : it
    serializer = if public
      "Public::#{payload.try(:klass) || payload.class}Serializer".constantize
    else
      "#{payload.try(:klass) || payload.class}Serializer".constantize
    end
    possible_relations = serializer.relationships_to_serialize
    if possible_relations && !options.has_key?(:include)
      if options[:fields].presence
        possible_relations = possible_relations.slice(*options[:fields].keys)
      end
      options[:include] = possible_relations.keys
    end

    begin
      ser = serializer.new(it, options)
      body = ser.serialized_json
      json_response body, status
    rescue ArgumentError
      jsonapi_422
    end
  end

  def error_response(errors)
    error_data, status = JsonApi::ErrorsSerializer.call(errors)
    json_response error_data, status
  end

  def jsonapi_422
    jsonapi_error(422, 'unprocessable_entity')
  end

  def jsonapi_404
    jsonapi_error(404, 'not_found')
  end

  def jsonapi_403
    jsonapi_error(403, 'forbidden')
  end

  def jsonapi_error(status, text)
    json_response({ errors: [{
      links:   {},
      status:  status,
      code:    text,
      title:   text,
      detail:  text,
      source:  {},
      meta:    {}
    }]}, status)
  end
end
