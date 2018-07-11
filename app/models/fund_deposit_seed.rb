class FundDepositSeed < ApplicationRecord
  include Garden::Seed
  include Garden::SelfHarvestable
  include Garden::Kindify

  validates :deposit_method, inclusion: { in: DepositMethod.all.map(&:code) }
  validates :currency, inclusion: { in: Currency.all.map(&:code) }
  kind_mask_for :deposit_method, "DepositMethod"
  kind_mask_for :currency, "Currency"
end
