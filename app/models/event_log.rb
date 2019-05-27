class EventLog < ApplicationRecord
  belongs_to :admin_user, optional: true
  belongs_to :entity, polymorphic: true, optional: true
  ransackable_static_belongs_to :verb, class_name: 'EventLogKind'  

  serialize :raw_data, JSON

  def data
    Hashie::Mash.new(raw_data)
  end

  def self.log_entity!(entity, user, verb)
    raw_data = "#{entity.class.name}Serializer".constantize.new(
      entity,
      {include: entity.class.try(:included_for)}
    )
  
    EventLog.create!(
      entity: entity,
      raw_data: raw_data.as_json,
      admin_user: user,
      verb: verb)
  end
end
