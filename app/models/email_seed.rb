class EmailSeed < ApplicationRecord
  include Garden::Seed
  include Garden::Kindify

  validates :email_kind, inclusion: { in: EmailKind.all.map(&:code) }

  kind_mask_for :email_kind, "EmailKind"
end
