class FundDeposit < ApplicationRecord
  include Loggable
  include StaticModels::BelongsTo

  validates :external_id, presence: true
  validates :deposit_method, inclusion: { in: DepositMethod.all }
  validates :currency, inclusion: { in: Currency.all }

  belongs_to :person
  belongs_to :deposit_method
  belongs_to :currency

  has_many :attachments, as: :attached_to_fruit

  def name
    "##{id}: #{amount} #{currency_code} #{deposit_method_code}"
  end
end
