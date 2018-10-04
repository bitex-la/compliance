class FundDeposit < ApplicationRecord
  include Loggable

  validates :external_id, presence: true
  validates :deposit_method, inclusion: { in: DepositMethod.all }
  validates :currency, inclusion: { in: Currency.all }

  belongs_to :person
  ransackable_static_belongs_to :deposit_method
  ransackable_static_belongs_to :currency

  has_many :attachments, as: :attached_to_fruit

  def name
    "##{id}: #{amount} #{currency_code} #{deposit_method_code}"
  end
end
