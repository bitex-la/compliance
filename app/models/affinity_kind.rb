class AffinityKind
  include StaticModels::Model

  static_models_dense [
    [:id, :code, :inverse_of, :associated_tag],
    [10, :spouse],
    [15, :business_partner],
    [20, :couple],
    [25, :manager],
    [30, :owner, :owns],
    [35, :immediate_family],
    [40, :extended_family],
    [45, :customer, :provider],
    [50, :other],
    [55, :stakeholder, :shareholder_of],
    [60, :partner],
    [65, :payee, :payer, :payee],
    [70, :payer, :payee, :payer],
    [75, :provider, :customer],
    [80, :compliance_liaison, :compliance_liaison_for]
  ]

  def name
    code
  end

  def inverse
    inverse_of || "#{code}_of".to_sym
  end

  def self.with_associated_tags
    all.select { |affinity_kind| affinity_kind.associated_tag }
  end
end
