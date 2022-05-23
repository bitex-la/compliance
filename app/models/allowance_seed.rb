class AllowanceSeed < AllowanceBase
  include Garden::Seed

  after_create :update_person_tpi

  def update_person_tpi
    person.update!(tpi: tpi) if tpi
  end
end
