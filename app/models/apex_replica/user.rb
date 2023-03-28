return
module ApexReplica
  class User < Base
    has_many :user_configs
    has_and_belongs_to_many :accounts, join_table: 'user_account_map'
    has_one :default_account, class_name: 'Account', foreign_key: :account_id

    def otp_seed
      configs = user_configs.to_a
      type = configs.find { |c| c.config_id == '2FAType' }.config_value
      seed = configs.find { |c| c.config_id == 'GooglePassPhrase' }.config_value
      seed = Base32.encode(seed).gsub(/=/, '') if type == 'Google'
      seed
    end

    def totp
      ROTP::TOTP.new(otp_seed)
    end

    def otp_code
      totp.now
    end
  end
end
