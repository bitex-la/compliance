class Event::EventLogger
  def self.call(entity, user, verb)
    klass = entity.class.name
    EventLog.create!(
      entity: entity,
      raw_data: "#{klass}Serializer".constantize.new(
        entity,
        {include: klass.constantize.included_for}
      ).serialized_json,
      admin_user: user,
      verb: verb
    )
  end
end
