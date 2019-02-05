FactoryBot.define do 
  factory :basic_task, class: Task do
    task_type { create(:generic_robot_task) }
    max_retries { 3 }
  end
end