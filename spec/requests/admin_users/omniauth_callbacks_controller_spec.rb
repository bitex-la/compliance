# frozen_string_literal: true

require 'rails_helper'

describe AdminUsers::OmniauthCallbacksController do
  mock_omniauth!
  let(:user_email) { 'somebitexemployee@bitex.la' }
  let(:omniauth_hash) { build(:google_auth_hash, email: user_email) }

  context 'when an admin user with the email exists' do
    let!(:admin_user) { create(:admin_user, email: user_email) }

    it 'redirects to admin' do
      get '/auth/google_oauth2/callback'
      expect(flash[:notice]).to match(/Successfully authenticated from Google account/)
      expect(response).to redirect_to(dashboards_path)
    end
  end

  it 'redirects to root path when admin user with email doesnt exist' do
    get '/auth/google_oauth2/callback'
    expect(flash[:alert]).to match(/Could not authenticate you from Google because "user not allowed"/)
    expect(response).to redirect_to(root_path)
  end
end
