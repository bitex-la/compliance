module FeatureHelpers
  def login_as(admin_user)
    visit admin_user_session_path
    fill_in 'admin_user[email]', with: admin_user.email
    fill_in 'admin_user[password]', with: admin_user.password
    click_button 'Login'
  end
end

RSpec.configuration.include FeatureHelpers, type: :feature
