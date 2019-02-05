FactoryBot.define do 
  factory :basic_workflow, class: Workflow do
    association :issue, factory: :basic_issue
    workflow_kind_code { 'onboarding' }
    scope { 'robot' }
  end
end