return
module ApexReplica
  class Account < Base
    self.primary_key = :account_id

    has_and_belongs_to_many :users, join_table: 'user_account_map'
    has_many :account_configs
    has_one :user

    def self.instance_method_already_implemented?(method_name)
      %w[frozen frozen?].include?(method_name) || super
    end

    def bitex_user_id
      user.user_configs.find_by(config_id: 'bitex_user_id')&.config_value ||
        account_configs.find_by(config_id: 'bitex_user_id')&.config_value
    end
  end
end
