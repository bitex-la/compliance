class AllowanceSeed < ApplicationRecord
  include Garden::Seed
  include Garden::Kindify

  kind_mask_for :kind, "Currency"
end
