require 'rails_helper'

describe AdminUser do
  it "auto-generates an api_token" do
    AdminUser.create(
      email: 'example@example.com',
      password: 'something',
      password_confirmation: 'something'
    ).api_token.should be_a(String)
  end
end
