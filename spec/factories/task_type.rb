FactoryBot.define do
  factory :generic_robot_task, class: 'TaskType' do 
    name { 'Run something in background' }
    description { 'Check is x third-party service for useful data' }
  end
end