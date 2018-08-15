class Email < ApplicationRecord
  include Garden::Fruit
  include StaticModels::BelongsTo

  validates :email_kind, inclusion: { in: EmailKind.all }

  belongs_to :email_kind, class_name: "EmailKind"

  def name
    [self.class.name, id, address, email_kind].join(',')
  end
end
