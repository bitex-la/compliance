class AllowanceBase < ApplicationRecord
  self.abstract_class = true
  ransackable_static_belongs_to :kind, class_name: "Currency"

  def name_body
    "#{amount} #{kind}"
  end
  enum tpi: { usd_5000_to_10000: 1,
              usd_10000_to_20000: 2,
              usd_20000_to_50000: 3,
              usd_50000_to_100000: 4,
              usd_100000: 5 }
end
