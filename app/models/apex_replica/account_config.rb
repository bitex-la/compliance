module ApexReplica
  class AccountConfig < Base
    self.table_name = 'account_config'

    belongs_to :account
  end
end
