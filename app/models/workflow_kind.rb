class WorkflowKind
  include StaticModels::Model
  
  static_models_sparse [
    [1, :onboarding]
  ]
 
  def name
    code
  end
 end