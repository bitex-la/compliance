class Phone < PhoneBase
  include Garden::Fruit

  def self.name_body(i)
    i.number
  end
end
