class EmailSeed < ApplicationRecord
  include Garden::Seed
  include Garden::Kindify

  kind_mask_for :email_kind, "EmailKind"
end
