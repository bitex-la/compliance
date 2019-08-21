class Api::DomicilesController < Api::ReadOnlyEntityController
  def resource_class
    Domicile
  end
end
