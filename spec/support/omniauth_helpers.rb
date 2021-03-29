# frozen_string_literal: true

RSpec.configure do |config|
  config.extend(Module.new do
    def mock_omniauth!
      before do
        OmniAuth.config.test_mode = true
        OmniAuth.config.mock_auth[:google_oauth2] = omniauth_hash

        Rails.application.env_config['devise.mapping'] = Devise.mappings[:admin_user]
        Rails.application.env_config['omniauth.auth'] = omniauth_hash
      end

      after do
        OmniAuth.config.test_mode = false
      end
    end
  end)
end
