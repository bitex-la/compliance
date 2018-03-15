class Email < ApplicationRecord
  include Garden::Fruit

  def name
    [id, address, kind].join(',')
  end
end
