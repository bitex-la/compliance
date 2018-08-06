require 'rails_helper'

describe 'an admin user' do
  let(:admin_user) { create(:admin_user) }

  it 'Fix an orphaned attachment' do
    person = create :full_natural_person
    person.should be_enabled
    
    orphan = create :orphan_attachment, person: person

    person.natural_docket.attachments.count.should == 5

    login_as admin_user
    click_link('Orphan Attachments')
    within("#attachment_#{orphan.id}") do
      click_link('Attach to fruit')
    end

    page.current_path.should == "/attachments/#{orphan.id}/attach"
    select "#{person.natural_docket.name}",
      from: "fruit",
      visible: false
 
    click_button "Attach"
    person.natural_docket.reload.attachments.count.should == 6
  end
end