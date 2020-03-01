class FundWithdrawal < ApplicationRecord
  include Loggable

  validates :currency, inclusion: { in: Currency.all }
  validates :amount, :exchange_rate_adjusted_amount,
            numericality: { greater_than: 0 }
  validates :withdrawal_date, presence: true

  belongs_to :person
  ransackable_static_belongs_to :currency

  has_many :attachments, as: :attached_to_fruit

  # after_save :refresh_person_withdrawal_regularity!
  after_save{ person.expire_action_cache }

  private

  def refresh_person_withdrawal_regularity!
    person.fund_withdrawals.reload
    person.refresh_person_withdrawal_regularity! #TODO
  end

end
