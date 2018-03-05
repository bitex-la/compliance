FactoryBot.define do
  factory :observation_reason do
    subject "Attachments are not in the ideal resolution"
    body    "Please add new attachments with a better resolution and quality"
    scope :client
  end

  factory :world_check_reason do
    subject "A worldcheck check must be run"
    body "Run the check!!!!"
    scope :robot
  end
end
