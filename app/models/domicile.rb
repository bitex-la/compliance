class Domicile < DomicileBase
  include Garden::Fruit
  
  def self.name_body(i)
    "#{i.city}, #{[i.street_address, i.street_number].join(' ')}"
  end
end
