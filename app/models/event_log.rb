class EventLog < ApplicationRecord
  belongs_to :admin_user, optional: true
  belongs_to :entity, polymorphic: true, optional: true
  ransackable_static_belongs_to :verb, class_name: 'EventLogKind'  

  serialize :raw_data, JSON

  after_commit :publish!, on: :create

  def publish!
    self.class.sqs_client.send_message(
      queue_url: Settings.sqs.queue,
      message_body: %i[id entity_type entity_id verb_code].map { |k| [k, send(k)] }.to_h.to_json,
      message_group_id: entity_type,
      message_deduplication_id: id.to_s
    )
  end

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

  def self.sqs_client
    @sqs_client ||= Aws::SQS::Client.new(Settings.sqs.credentials.to_h.symbolize_keys)
  end

  def self.purge_sqs_queue
    sqs_client.purge_queue(queue_url: Settings.sqs.queue)
  end

  def self.sqs_poller
    @sqs_poller ||= Aws::SQS::QueuePoller.new(Settings.sqs.queue, client: sqs_client)
  end
end
