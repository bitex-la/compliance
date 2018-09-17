FactoryBot.define do
  factory :observation do
    observation_reason
    note { "Si puede ser, sinó no se moleste." }
    scope { :client }
  end

  factory :robot_observation, class: 'Observation' do
    association :observation_reason, factory: :world_check_reason
    note { "Performed by sidekiq" }
    scope { 'robot' }

    factory :robot_observation_with_issue do
      observation_reason { create(:world_check_reason) }
      association :issue, factory: :basic_issue
    end
  end

  factory :admin_world_check_observation, class: 'Observation' do
    association :observation_reason, factory: :human_world_check_reason
    note { "Please perform a worldcheck review against the person" }
    scope { 'admin' }

    factory :admin_world_check_observation_with_issue do
      observation_reason { create(:human_world_check_reason) }
      association :issue, factory: :basic_issue
    end
  end
end
