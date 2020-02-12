class AdminUser < ApplicationRecord
  enum role_type: [:restricted, :admin, :super_admin, :marketing, :admin_restricted]

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

  def request_limit_set
    now = Time.now
    now_string = now.strftime('%Y%m%d')
    expire_at = (now + 1.week).end_of_day
    Redis::Set.new("request_limit:people:#{id}:#{now_string}", :expireat => expire_at)
  end

  def request_limit_counter
    now = Time.now
    now_string = now.strftime('%Y%m%d')
    expire_at = (now + 1.week).end_of_day
    Redis::Counter.new("request_limit:counter:#{id}:#{now_string}", :expireat => expire_at)
  end

  def renew_otp_secret_key!
    return if otp_enabled?

    self.otp_secret_key = ROTP::Base32.random_base32
    save!
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
