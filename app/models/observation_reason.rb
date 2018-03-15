class ObservationReason < ApplicationRecord
  enum scope: %i(client robot admin)   

  def name
    subject.truncate(140)
  end
end
