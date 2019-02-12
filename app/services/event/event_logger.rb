class Event::EventLogger
  def self.call(entity, user, verb)
    klass = entity.class.name

    serializer = "#{klass}Serializer".constantize
    relations = serializer.relationships_to_serialize
    options = {}
    options[:include] = relations.keys
    
    relations.keys.each do |name|
      naming = Garden::Naming.new(name)
      naming.serializer.constantize
    end

    ser = serializer.new(entity, options)
    body = ser.serialized_json

    EventLog.create!(
      entity: entity,
      raw_data: body,
      admin_user: user,
      verb: verb
    )
  end
end
