class Email < ApplicationRecord
  include Garden::Fruit
  include StaticModels::BelongsTo

  validates :email_kind, inclusion: { in: EmailKind.all }

  belongs_to :email_kind

  def name
    build_name("#{address} #{email_kind}")
  end
end
