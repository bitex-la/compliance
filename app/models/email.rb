class Email < ApplicationRecord
  include Garden::Fruit
  include Garden::Kindify

  kind_mask_for :email_kind, "EmailKind"

  def name
    [id, address, email_kind].join(',')
  end
end
