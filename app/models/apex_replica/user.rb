return
module ApexReplica
  class User < Base
    has_many :user_configs
    has_and_belongs_to_many :accounts, join_table: 'user_account_map'
    belongs_to :account

    def otp_seed
      return @seed if @seed

      configs = user_configs.to_a
      type = configs.find { |c| c.config_id == '2FAType' }&.config_value
      return unless type.present?

      seed = configs.find { |c| c.config_id == 'GooglePassPhrase' }&.config_value
      return unless seed.present?

      seed = Base32.encode(seed).gsub(/=/, '') if type == 'Google'
      @seed = seed
    end

    def totp
      return unless otp_seed

      ROTP::TOTP.new(otp_seed)
    end

    def otp_code
      totp.now
    end
  end
end
