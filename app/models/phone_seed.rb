class PhoneSeed < ApplicationRecord
  include Garden::Seed
  include Garden::Kindify

  kind_mask_for :phone_kind, "PhoneKind"
end
