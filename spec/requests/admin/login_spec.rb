require 'rails_helper'

describe 'Login' do
  it 'Can log with disabled otp' do
    admin_user = create(:admin_user, otp_enabled: false)

    post '/login', params: {
      "admin_user[email]": admin_user.email,
      "admin_user[password]": 'mysecurepassword',
      "commit": 'Login'
    }

    expect(request.env['warden.options']).to be_nil
  end

  it 'Can log with enabled otp' do
    admin_user = create(:admin_user, otp_enabled: true)

    post '/login', params: {
      "admin_user[email]": admin_user.email,
      "admin_user[password]": 'mysecurepassword',
      "admin_user[otp]": admin_user.otp_code,
      "commit": 'Login'
    }

    expect(request.env['warden.options']).to be_nil
  end

  it 'Cannot log with enabled nil otp' do
    admin_user = create(:admin_user, otp_enabled: true)

    post '/login', params: {
      "admin_user[email]": admin_user.email,
      "admin_user[password]": 'mysecurepassword',
      "commit": 'Login'
    }

    expect(request.env['warden.options'][:message]).to eq('Invalid OTP')
  end

  it 'Cannot log with enabled blank otp' do
    admin_user = create(:admin_user, otp_enabled: true)

    post '/login', params: {
      "admin_user[email]": admin_user.email,
      "admin_user[password]": 'mysecurepassword',
      "admin_user[otp]": '',
      "commit": 'Login'
    }

    expect(request.env['warden.options'][:message]).to eq('Invalid OTP')
  end

  it 'Cannot log with enabled invalid otp' do
    admin_user = create(:admin_user, otp_enabled: true)

    post '/login', params: {
      "admin_user[email]": admin_user.email,
      "admin_user[password]": 'mysecurepassword',
      "admin_user[otp]": '12345',
      "commit": 'Login'
    }

    expect(request.env['warden.options'][:message]).to eq('Invalid OTP')
  end
end
