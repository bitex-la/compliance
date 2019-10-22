class AdminUser < ApplicationRecord
  enum role_type: [:restricted, :admin, :super_admin, :marketing]

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable, :validatable

  has_one_time_password
  attr_accessor :otp

  has_secure_token :api_token
  after_initialize :set_api_token

  def is_restricted?
    role_type == "restricted"
  end

  def is_super_admin?
    role_type == "super_admin"
  end

  def is_in_role?(role)
    role_type == role
  end

  private

  def set_api_token
    self.api_token = Digest::SHA256.hexdigest SecureRandom.hex if api_token.nil? 
  end

  class << self
    def current_admin_user=(user)
      Thread.current[:current_admin_user] = user
    end

    def current_admin_user
      Thread.current[:current_admin_user]
    end
  end
end

Warden::Manager.after_authentication scope: :admin_user do |user, warden, options|
  next unless user.otp_enabled?
  proxy = Devise::Hooks::Proxy.new(warden)
  unless user.authenticate_otp(warden.request.params[:admin_user][:otp])
    proxy.sign_out(:admin_user)
    throw :warden, scope: :admin_user, message: 'Invalid OTP'
  end
end