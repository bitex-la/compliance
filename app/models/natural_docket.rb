class NaturalDocket < NaturalDocketBase
  include Garden::Fruit
  def self.name_body(i)
    [i.first_name, i.last_name].join(' ')
  end
end
