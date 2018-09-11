class Api::AllowancesController < Api::PersonJsonApiController
  def resource_class
    Allowance
  end
end
