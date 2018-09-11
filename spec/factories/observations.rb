FactoryBot.define do
  factory :observation do
    observation_reason
    note { "Si puede ser, sinó no se moleste." }
    scope { :client }
  end

  factory :robot_observation, class: 'Observation' do
    association :observation_reason, factory: :world_check_reason
    note { "Performed by sidekiq" }
    scope { :robot }
  end

  factory :admin_world_check_observation, class: 'Observation' do
    association :observation_reason, factory: :human_world_check_reason
    note { "Please perform a worldcheck review against the person" }
    scope { :admin }
  end
end
