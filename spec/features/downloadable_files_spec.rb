require 'rails_helper'

describe 'an admin user' do
  let(:admin_user) { create(:admin_user) }

  describe 'download user KYC files' do
    it 'enabled person' do
      person = create :full_natural_person

      person.should be_enabled

      login_as admin_user
      click_link('People')
      click_link('All')

      within("#person_#{person.id} td.col.col-actions") do
        click_link('View')
      end
      expect(page.current_path).to eq("/people/#{person.id}")
    end

    it 'rejected person' do
      person = create :new_natural_person

      person.enable
      person.reload

      login_as admin_user
      click_link('People')
      click_link('All')

      within("#person_#{person.id} td.col.col-actions") do
        click_link('View')
      end

      click_link('Reject')
    end

    after(:each) do
      open_download_profile_actions_menu('Basic')
      DownloadHelpers.wait_for_download
      expect(File.basename(DownloadHelpers.download)).to eq('person_1_kyc_files.zip')

      Zip::File.open(DownloadHelpers.download) do |zip_file|
        zip_file.each do |entry|
          next unless entry.name == 'profile.pdf'

          text = PDF::Inspector::Text.analyze(entry.get_input_stream.read).strings
          expect(text).to include('First Name: Joe')
          expect(text).to include('Kind: national_id')
          expect(text).to include('Number: +5491125410470')
          expect(text).to include(/Address: \w*@\w*/)
          expect(text).to include('State: Buenos Aires')
        end
      end
    end
  end
end
