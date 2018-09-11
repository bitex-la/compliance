Dir[Rails.root.join("app/serializers/**/*.rb")].each {|f| require f} 
class AbandonRepeatedIssues < ActiveRecord::Migration[5.1]
  def up 
    issues_dismissed = 0

    RiskScoreSeed.all.each do |seed|
      issue = seed.issue
      person = issue.person
      person.issues.where('id != ?', issue.id).each do |i|
        if i.observations.where(note: 'Nuevo score de riesgo desde chainalysis').count > 0
          i.state = 'dismissed'
          if i.save
            issues_dismissed += 1
            p "+++++++++++++++"
            p "Dismissed issue #{i.id} for person #{i.person.id}"
            p "---------------"
          else 
            p issue.errors
          end
        end
      end
    end

    p "Issues dismissed #{issues_dismissed}"
  end
end
