class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable, :validatable

  has_secure_token :api_token	
  after_initialize :set_api_token

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
