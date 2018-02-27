class Observation < ApplicationRecord
  belongs_to :issue
  belongs_to :observation_reason

  after_save :observe_issue
  
  def observe_issue
    issue.observe!
  end    	
end
