class AllowanceBase < ApplicationRecord
  self.abstract_class = true
  ransackable_static_belongs_to :kind, class_name: "Currency"

  def name_body
    "#{amount} #{kind}"
  end

  enum tpi: %i(_
               usd_5000_to_10000
               usd_10000_to_20000
               usd_20000_to_50000
               usd_50000_to_100000
               usd_100000)
end
