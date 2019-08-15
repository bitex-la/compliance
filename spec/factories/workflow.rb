FactoryBot.define do 
  factory :basic_workflow, class: Workflow do
    association :issue, factory: :basic_issue
    workflow_type { 'onboarding' }
    scope { 'robot' }
  end

  factory :admin_risk_check_workflow, class: Workflow do
    association :issue, factory: :basic_issue
    workflow_type { 'risk_check' }
    scope { 'admin' }
  end
end