class IssueReason
  include StaticModels::Model

  static_models_dense [
    [:id,   :code, :description],
    [1,     :new_client, 'New Client'],
    [2,     :update_expired_data , 'Update information for expired data'],
    [3,     :update_by_client, 'Update information by a client'],
    [4,     :new_risk_information, 'New Risk information']
  ]
end
