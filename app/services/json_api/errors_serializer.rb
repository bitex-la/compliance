class JsonApi::ErrorsSerializer
  def self.call(object, options = {})
    data        = { errors: [] }
    status_code = 0

    if object.kind_of?(Array)
      data[:errors] = object
      status = object[0].status
    elsif object.kind_of?(Hash)
      data = object
      status = object[:errors].first[:status]
    end
    #JsonApi::ErrorSerializer.new(data, options).serialized_json 
    [data.to_json, status]
  end

end