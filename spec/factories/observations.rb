FactoryBot.define do
  factory :observation do
    observation_reason
    note "Si puede ser, sinó no se moleste."
    scope :client
  end

  factory :robot_observation do
    world_check_reason
    note "Performed by sidekiq"
    scope :robot
  end
end
