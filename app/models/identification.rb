class Identification < IdentificationBase
  include Garden::Fruit
  def self.name_body(i)
    "#{i.identification_kind} #{i.number}, #{i.issuer}"
  end
end
