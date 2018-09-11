class ObserveByRiskScore < ActiveRecord::Migration[5.1]
  def up
    people_observed = 0

    RiskScoreSeed.all.each do |seed|
      issue = seed.issue
      if issue.state == 'new'
        reason = ObservationReason.where(scope: 'admin', subject_en: 'Risk score alert').first
        if reason && issue.observations.where(note: 'Nuevo score de riesgo desde chainalysis').count == 0
          p "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
          p "Adding risk score observation for #{issue.person.id} - on #{issue.id}"
          observation = Observation.new(
            issue: issue,
            observation_reason: reason, 
            scope: 'admin',
            aasm_state: 'new',
            note: "Nuevo score de riesgo desde chainalysis")
          if observation.save
            people_observed += 1
          else 
            p observation.errors
          end
          p "-------------------------------------------------------------------------------"
        end
      end
    end
    p "People observed: #{people_observed}"
  end
end
