class Api::AllowancesController < Api::ReadOnlyEntityController
  def resource_class
    Allowance
  end
end
