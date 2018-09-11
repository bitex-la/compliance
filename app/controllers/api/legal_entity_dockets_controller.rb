class Api::LegalEntityDocketsController < Api::FruitController
  def resource_class
    LegalEntityDocket
  end
end
