class IssueReason
  include StaticModels::Model

  static_models_dense [
    [:id,   :code, :description],
    [1,     :new_client, 'New Client'],
    [2,     :further_clarification , 'Further information required'],
    [3,     :update_expired_data , 'Update information for expired data'],
    [4,     :update_by_client, 'Update information by a client'],
    [5,     :new_risk_information, 'New Risk information']
  ]
end
