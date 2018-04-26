class Email < ApplicationRecord
  include Garden::Fruit
  include Garden::Kindify

  validates :email_kind, inclusion: { in: EmailKind.all.map(&:code) }

  kind_mask_for :email_kind, "EmailKind"

  def name
    [id, address, email_kind].join(',')
  end
end
