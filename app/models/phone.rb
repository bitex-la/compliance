class Phone < ApplicationRecord
  include Garden::Fruit

  def name
    [id, number, kind, country].join(',')
  end
end
