require 'rails_helper'

RSpec.describe Person, type: :model do
  it 'is valid without issues' do
    expect(Person.new).to be_valid
  end

  it 'knows which fruits can be replaced' do
    person = create(:full_natural_person)

    new_phone = create :full_phone, person: person
    person.reload.phones.first.update(replaced_by: new_phone)

    person.reload.replaceable_fruits.sort_by{|i| [i.class.name, i.id]}.should == [
      Allowance.first,
      Allowance.last,
      ArgentinaInvoicingDetail.first,
      Domicile.first,
      Email.first,
      Identification.first,
      NaturalDocket.first,
      Phone.last,
    ]
  end
end
