return
module ApexReplica
  class Base < ActiveRecord::Base
    self.abstract_class = true

    establish_connection :apex_replica if Rails.env.production?
  end
end
