class AffinityKind
  include StaticModels::Model

  static_models_dense [
    [:id, :code, :inverse_of],
    [10, :spouse, :spouse_of],
    [15, :business_partner, :business_partner_of],
    [20, :couple, :couple_of],
    [25, :manager, :managed_by],
    [30, :owner, :owns],
    [35, :immediate_family, :immediate_family_of],
    [40, :extended_family, :extended_family_of],
    [45, :customer, :provider],
    [50, :other, :other],
    [55, :stakeholder, :shareholder_of],
    [60, :partner, :partner_of],
    [65, :payee, :payer],
    [70, :payer, :payee],
    [75, :provider, :customer],
  ]

  def name
    code
  end
end
