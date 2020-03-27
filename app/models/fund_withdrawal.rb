class FundWithdrawal < ApplicationRecord
  include Loggable

  validates :country, country: true
  validates :withdrawal_date, presence: true
  validates :external_id, presence: true
  validates :currency, inclusion: { in: Currency.all }
  validates :amount, :exchange_rate_adjusted_amount,
            numericality: { greater_than: 0 }
  validates :withdrawal_date, presence: true

  belongs_to :person
  ransackable_static_belongs_to :currency

  has_many :attachments, as: :attached_to_fruit

  after_save :refresh_person_country_tagging!
  after_save { person.expire_action_cache }

  include PersonScopeable

  def name
    "##{id}: #{amount} #{currency_code} #{country}"
  end

  private

  def refresh_person_country_tagging!
    person.fund_withdrawals.reload
    person.refresh_person_country_tagging!(country)
  end
end
