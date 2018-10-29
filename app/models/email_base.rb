class EmailBase < ApplicationRecord
  strip_attributes
  self.abstract_class = true
  validates :email_kind, inclusion: { in: EmailKind.all }
  ransackable_static_belongs_to :email_kind

  def name_body
    address
  end
end
