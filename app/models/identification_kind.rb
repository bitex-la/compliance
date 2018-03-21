class IdentificationKind
  include StaticModels::Model
 
  static_models_sparse [
    [1, :passport],
    [2, :social_security_number],
    [3, :voter_card],
    [4, :tax_id],
    [5, :driver_license],
    [6, :foreign_id],
    [7, :national_id],
    [8, :company_registration]
  ] 

  def name
   code
  end
end
