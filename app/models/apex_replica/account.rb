module ApexReplica
  class Account < Base
    self.primary_key = :account_id

    has_and_belongs_to_many :users, join_table: 'user_account_map'
    has_many :account_configs

    def self.instance_method_already_implemented?(method_name)
      %w[frozen frozen?].include?(method_name) || super
    end

    def user
      users.first
    end
  end
end
