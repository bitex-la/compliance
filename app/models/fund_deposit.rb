class FundDeposit < ApplicationRecord
  include Garden::Fruit
  include Garden::Kindify

  validates :external_id, presence: true
  validates :deposit_method, inclusion: { in: DepositMethod.all.map(&:code) }
  validates :currency, inclusion: { in: Currency.all.map(&:code) }
  kind_mask_for :deposit_method, "DepositMethod"
  kind_mask_for :currency, "Currency"

  def name
    [id, amount, currency, deposit_method].join(',')
  end
end
