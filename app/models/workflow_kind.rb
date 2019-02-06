class WorkflowKind
  include StaticModels::Model
  
  static_models_sparse [
    [1, :onboarding],
    [2, :risk_check]
  ]
 
  def name
    code
  end
 end