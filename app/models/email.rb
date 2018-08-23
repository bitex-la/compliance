class Email < ApplicationRecord
  include Garden::Fruit
  include StaticModels::BelongsTo

  validates :email_kind, inclusion: { in: EmailKind.all }

  belongs_to :email_kind

  def self.name_body(i)
    i.address
  end
end
