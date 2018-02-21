class JsonApi::ModelSerializer
  def self.call(objects, options = {})
    klass = objects.try(:klass) || objects.class
    "#{klass}Serializer".constantize.new(objects, options).serialized_json 
  end
end
