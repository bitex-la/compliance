class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable,
    :rememberable, :trackable, :validatable

  has_one_time_password
  attr_accessor :otp

  has_secure_token :api_token
  after_initialize :set_api_token

  has_many :admin_user_taggings
  has_many :tags, through: :admin_user_taggings
  accepts_nested_attributes_for :admin_user_taggings, allow_destroy: true

  belongs_to :admin_role, required: true

  scope :active, -> { where(active: true) }

  def active_for_authentication?
    super && active?
  end

  def inactive_message
    active? ? super : 'Este usuario ha sido deshabilitado.'
  end

  def disable!
    raise DisableNotAuthorized, 'Not allowed to disable user' unless authorized_to_disable?

    update!(active: false)
  end

  def authorized_to_disable?
    admin_role.code == :super_admin || admin_role.code == :security
  end

  def request_limit_set
    now = Time.now
    now_string = now.strftime('%Y%m%d')
    expire_at = (now + 1.week).end_of_day
    Redis::SortedSet.new("request_limit:people:#{id}:#{now_string}", :expireat => expire_at)
  end

  def request_limit_rejected_set
    now = Time.now
    now_string = now.strftime('%Y%m%d')
    expire_at = (now + 1.week).end_of_day
    Redis::SortedSet.new("request_limit:rejected_people:#{id}:#{now_string}", :expireat => expire_at)
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

  def active_tags
    admin_user_taggings.pluck(:tag_id)
  end

  def can_manage_tag?(tag)
    !admin_user_taggings.exists? ||
      admin_user_taggings.where(tag: tag).exists?
  end

  def add_tag(tag)
    return if admin_user_taggings.empty?

    admin_user_taggings.find_or_create_by(tag: tag)
    tags.reload
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

  otp = warden.request.params.dig(:admin_user, :otp)
  unless otp && user.authenticate_otp(otp)
    proxy = Devise::Hooks::Proxy.new(warden)
    proxy.sign_out(:admin_user)
    throw :warden, scope: :admin_user, message: 'Invalid OTP'
  end
end

class DisableNotAuthorized < StandardError; end
