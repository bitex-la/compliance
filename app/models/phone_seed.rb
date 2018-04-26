class PhoneSeed < ApplicationRecord
  include Garden::Seed
  include Garden::Kindify

  validates :phone_kind, inclusion: { in: PhoneKind.all.map(&:code) }

  kind_mask_for :phone_kind, "PhoneKind"
end
