class Allowance < AllowanceBase
  include Garden::Fruit

  after_create :update_person_ipt

  def update_person_ipt
    person.update!(ipt: ipt) if ipt
  end
end
