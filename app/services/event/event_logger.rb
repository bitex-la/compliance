class Event::EventLogger
  def self.call(entity, user, verb)
    klass = entity.class.name
    EventLog.create!(
      entity: entity,
      raw_data: "#{klass}Serializer".constantize.new(
        raw_data: body,
        entity,
        {include: klass.constantize.try(:included_for)}
      ).serialized_json,
      admin_user: user,
      verb: verb
    )
  end
end
