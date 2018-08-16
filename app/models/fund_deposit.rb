class FundDeposit < ApplicationRecord
  include Garden::Fruit
  include StaticModels::BelongsTo

  validates :external_id, presence: true
  validates :deposit_method, inclusion: { in: DepositMethod.all }
  validates :currency, inclusion: { in: Currency.all }

  belongs_to :deposit_method
  belongs_to :currency

  def name
    build_name("#{amount} #{currency} #{deposit_method}")
  end
end
