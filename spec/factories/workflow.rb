FactoryBot.define do 
  factory :basic_workflow, class: Workflow do
    association :issue, factory: :basic_issue
    workflow_kind_code { 'onboarding' }
    scope { 'robot' }
  end

  factory :admin_risk_check_workflow, class: Workflow do
    association :issue, factory: :basic_issue
    workflow_kind_code { 'risk_check' }
    scope { 'admin' }
  end
end