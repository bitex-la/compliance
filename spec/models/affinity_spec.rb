require 'rails_helper'

describe Affinity do
  it 'has a custom name_body' do
    person = create(:basic_issue).reload.person
    create(:full_affinity, person: person)
      .name.should =~ /Affinity#[0-9]*?: business_partner/
  end
end
