class ObservationReason < ApplicationRecord
 
  def name
    subject.truncate(140)
  end
end
