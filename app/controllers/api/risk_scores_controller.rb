class Api::RiskScoresController < Api::ReadOnlyEntityController
  def resource_class
    RiskScore
  end

  def related_person
    resource.person_id
  end
end
