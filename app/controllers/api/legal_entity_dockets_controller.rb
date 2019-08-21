class Api::LegalEntityDocketsController < Api::ReadOnlyEntityController
  def resource_class
    LegalEntityDocket
  end
end
