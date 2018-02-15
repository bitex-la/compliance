class JsonApi::ModelSerializer
  def self.call(objects, options = {})
    klass =
      if objects.respond_to?(:each)
        "#{objects.klass.name}"
      else
        "#{objects.class.name}"
      end
    "#{klass}Serializer".constantize.new(objects, options).serialized_json 
  end
end