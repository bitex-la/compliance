class ObservationReason < ApplicationRecord
  enum scope: %i(client robot admin)   

  scope :for_client, -> { where('scope = ?', 0) }
  scope :for_admin,  -> { where('scope = ?', 1) }
  scope :for_robot,  -> { where('scope = ?', 2) }

  ransacker("scope",
    formatter: proc { |v| scopes[v] }
  ){|parent| parent.table["scope"] }


  def name
    subject_en.truncate(40, omission:'…')
  end
end
