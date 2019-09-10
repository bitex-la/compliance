require 'rails_helper'

describe 'an admin user' do
  let(:admin_user) { create(:admin_user) }

  it 'download user KYC files' do
    person = create :full_natural_person
    
    person.should be_enabled

    login_as admin_user
    click_link('People')
    click_link('All')
    
    within("#person_#{person.id} td.col.col-actions") do
      click_link('View')
    end
    page.current_path.should == "/people/#{person.id}"
    click_link('Download Profile')
  end

  it 'cannot download files from detail if person does not have attachments' do
    person = create(:empty_person)
    person.should_not be_enabled
    expect(person.state).to eq('new')

    login_as admin_user
    click_link('People')
    within("#person_#{person.id} td.col.col-actions") do
      click_link('View')
    end
    page.current_path.should == "/people/#{person.id}"
    page.should_not have_content 'Download Profile'
  end
end