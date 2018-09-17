class Email < EmailBase
  include Garden::Fruit

  def self.name_body(i)
    i.address
  end
end
