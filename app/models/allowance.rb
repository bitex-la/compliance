class Allowance < AllowanceBase
  include Garden::Fruit

  def self.name_body(i)
    "#{i.amount} #{i.kind}"
  end
end
