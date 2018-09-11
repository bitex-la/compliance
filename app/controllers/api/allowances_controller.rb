class Api::AllowancesController < Api::FruitController
  def resource_class
    Allowance
  end
end
