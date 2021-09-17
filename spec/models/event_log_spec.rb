require 'rails_helper'

RSpec.describe EventLog, type: :model do
  it 'works' do
    EventLog.sqs_client.purge_queue(queue_url: Settings.sqs.queue)
  end
end
