class FundWithdrawal < ApplicationRecord
  include Loggable
  include PersonScopeable

  validates :country, country: true
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

  validate :withdrawal_date_cannot_be_in_the_future

  def withdrawal_date_cannot_be_in_the_future
    return unless withdrawal_date.present? && withdrawal_date > DateTime.now.utc

    errors.add(:withdrawal_date, 'cannot be in the future')
  end

  def name
    "##{id}: #{amount} #{currency_code} #{country}"
  end

  private

  def refresh_person_country_tagging!
    person.refresh_person_country_tagging!(country)
  end
end
