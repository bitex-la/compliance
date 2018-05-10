class ObservationReason < ApplicationRecord
  enum scope: %i(client robot admin)   

  scope :for_client, -> { where('scope = ?', 0) }
  scope :for_admin,  -> { where('scope = ?', 1) }
  scope :for_robot,  -> { where('scope = ?', 2) }

  def name
    subject_en.truncate(140)
  end
end
