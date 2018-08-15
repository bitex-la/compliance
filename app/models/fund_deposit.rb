class FundDeposit < ApplicationRecord
  include Garden::Fruit
  include StaticModels::BelongsTo

  validates :external_id, presence: true
  validates :deposit_method, inclusion: { in: DepositMethod.all }
  validates :currency, inclusion: { in: Currency.all }

  belongs_to :deposit_method, class_name: "DepositMethod"
  belongs_to :currency, class_name: "Currency"

  def name
    [self.class.name, id, amount, currency, deposit_method].join(',')
  end
end
