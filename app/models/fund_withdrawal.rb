class FundWithdrawal < ApplicationRecord
  include Loggable

  validates :external_id, presence: true
  validates :currency, inclusion: { in: Currency.all }
  validates :amount, :exchange_rate_adjusted_amount,
            numericality: { greater_than: 0 }
  validates :withdrawal_date, presence: true

  belongs_to :person
  ransackable_static_belongs_to :currency

  has_many :attachments, as: :attached_to_fruit

  after_save { person.expire_action_cache }

  include PersonScopeable

  def name
    "##{id}: #{amount} #{currency_code} #{country}"
  end
end
