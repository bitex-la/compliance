class FundTransfer < ApplicationRecord
    include Loggable

    validates :currency, inclusion: { in: Currency.all }
    validates :amount, :exchange_rate_adjusted_amount,
              numericality: { greater_than: 0 }
    validates :transfer_date, presence: true

    belongs_to :source_person, class_name: 'Person'
    belongs_to :target_person, class_name: 'Person'
    ransackable_static_belongs_to :currency

    def name
        "##{id}: #{source_person.name} -> #{target_person.name} (#{amount} #{currency_code})"
      end
end
